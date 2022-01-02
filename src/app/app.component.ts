import { Component } from '@angular/core';

export type FormType = "text" | "upload";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {

  title = 'JSON Parser';

  form: FormType = 'text';

  get isTextType() {
    return this.form === "text";
  }

  get isUploadType() {
    return this.form === "upload";
  }

  toggleForm(type: FormType) {
    this.form = type;
  }
}
