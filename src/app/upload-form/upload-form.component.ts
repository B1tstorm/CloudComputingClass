import {Component, ElementRef, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {Subscription} from "rxjs";
import {JsonResponse, UploadService} from "../upload.service";
import {webSocket} from "rxjs/webSocket";

@Component({
  selector: 'app-upload-form',
  templateUrl: './upload-form.component.html',
  styleUrls: ['./upload-form.component.css']
})
export class UploadFormComponent implements OnInit {

  jsonResponse: JsonResponse | undefined;

  file: File | null = null;

  stringResponse: String | undefined;

  // This is a reference to the fileInput element in the dom, to empty its value
  // so the same file can be added twice, both times triggering the change event
  // otherwise it would not be triggered since there is not "change"
  @ViewChild('fileInput') fileInputElement!: ElementRef;

  constructor(
    private uploadService: UploadService,
  ) {
  }

  onFileInput(files: FileList | null): void {
    if (files) {
      this.file = files.item(0);
    }
  }

  onSubmit() {
    if (this.file) {
      this.uploadService
        .uploadFile(this.file)
        .subscribe(response => {
            this.jsonResponse = {...response}
            this.fileInputElement.nativeElement.value = '';
            
            const subject = webSocket<String>("ws://localhost:3333/websocket?id=" + this.jsonResponse.clientId);
            subject.subscribe(
              msg => this.stringResponse = JSON.stringify(msg),
              error => console.log(error),
              () => console.log("complete")
            )
          }
        )
    }
  }

  onReset() {
    this.fileInputElement.nativeElement.value = '';
    this.file = null;
  }

  ngOnInit(): void {
  }
}
