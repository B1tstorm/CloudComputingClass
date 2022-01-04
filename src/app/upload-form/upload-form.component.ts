import {Component, OnDestroy, OnInit} from '@angular/core';
import {Subscription} from "rxjs";
import {UploadService} from "../upload.service";

@Component({
  selector: 'app-upload-form',
  templateUrl: './upload-form.component.html',
  styleUrls: ['./upload-form.component.css']
})
export class UploadFormComponent implements OnInit, OnDestroy {

  file: File | null = null;

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

  answer: string | null = null;

  onAsk() {
    this.uploads.getAnswer().subscribe(answer => (this.answer = answer.some));
  }

  ngOnInit(): void {
  }

  ngOnDestroy(): void {
    this.subscription?.unsubscribe();
  }
}
