import {Component, ElementRef, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {Subscription} from "rxjs";
import {UploadService} from "../upload.service";

@Component({
  selector: 'app-upload-form',
  templateUrl: './upload-form.component.html',
  styleUrls: ['./upload-form.component.css']
})
export class UploadFormComponent implements OnInit, OnDestroy {

  file: File | null = null;

  // This is a reference to the fileInput element in the dom, to empty its value
  // so the same file can be added twice, both times triggering the change event
  // otherwise it would not be triggered since there is not "change"
  @ViewChild('fileInput') fileInputElement!: ElementRef;

  private subscription: Subscription | undefined;

  constructor( private uploads: UploadService) { }

  onFileInput(files: FileList | null): void {
    if(files) {
      this.file = files.item(0);
    }
  }

  onSubmit() {
    if(this.file) {
      this.subscription = this.uploads.upload(this.file).subscribe();
    }
  }

  onReset() {
    this.fileInputElement.nativeElement.value = '';
    this.file = null;
  }

  answer: string | null = null;

  onAsk() {
    this.uploads.getAnswer().subscribe(answer => (this.answer = answer));
  }

  ngOnInit(): void {
  }

  ngOnDestroy(): void {
    this.subscription?.unsubscribe();
  }
}
