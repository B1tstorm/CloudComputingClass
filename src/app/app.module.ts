import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule} from "@angular/common/http";

import { AppComponent } from './app.component';
import { TextFormComponent } from './text-form/text-form.component';
import { UploadFormComponent } from './upload-form/upload-form.component';

@NgModule({
  declarations: [
    AppComponent,
    TextFormComponent,
    UploadFormComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
