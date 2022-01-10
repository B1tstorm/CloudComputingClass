import {Injectable} from '@angular/core';
import {HttpClient, HttpErrorResponse, HttpEvent, HttpEventType, HttpHeaders} from "@angular/common/http";
import {catchError, last, map, of, tap} from "rxjs";

import {MessageService} from "./message.service";
import {environment} from "../environments/environment";

@Injectable({
  providedIn: 'root'
})
export class UploadService {

  constructor(
    private http: HttpClient,
    private messenger: MessageService
  ) {
  }

  uploadFile(file: File) {
    if (!file) {
      return of("No file was provided.")
    }

    const data = new FormData();
    data.append('file', file)

    return this.http.post(environment.NODE_API_URL + '/api/file', data, {
      reportProgress: true,
      observe: "events"
    }).pipe(
      map(event => this.getEventMessage(event, file)),
      tap(message => this.showProgress(message)),
      last(),
      catchError(this.handleFileError(file))
    );
  }

  sendJson(jsonString: String) {
    if (!jsonString) {
      return of("No jsonString provided")
    }

    const httpHeaders = new HttpHeaders()
      .set('content-type', 'application/json');

    return this.http.post(environment.NODE_API_URL + '/api/json', jsonString, {
      headers: httpHeaders,
      observe: "body",
      responseType: "json"
    }).pipe(
      catchError(this.handleJsonError(jsonString))
    )
  }


  private getEventMessage(event: HttpEvent<any>, file: File) {
    switch (event.type) {
      case HttpEventType.Sent:
        return `Uploading file ${file.name} of size ${file.size}.`;

      case HttpEventType.UploadProgress:
        const percentDone = Math.round(100 * event.loaded / (event.total ?? 0));
        return `File ${file.name} is ${percentDone}% uploaded...`

      case HttpEventType.Response:
        return `File ${file.name} was completely uploaded.`

      case HttpEventType.ResponseHeader:
        return `Response Header ${event.type}.`

      case HttpEventType.User:
        return `User ${event.type}.`

      case HttpEventType.DownloadProgress:
        return `Download Progress ${event.type}.`
    }
  }


  private handleFileError(file: File) {
    const userMessage = `${file.name} upload failed`;

    return (error: HttpErrorResponse) => {
      console.error(error); // log to console instead

      const message = (error.error instanceof Error) ?
        error.error.message :
        `server returned code ${error.status} with body "${error.error}"`;

      this.messenger.add(`${userMessage} ${message}`);

      // Let app keep running but indicate failure.
      return of(userMessage);
    };
  }

  private handleJsonError(string: String) {
    return (error: HttpErrorResponse) => {
      return of("Error handling the POST request")
    }
  }

  private showProgress(message: string) {
    this.messenger.add(message);
  }
}
