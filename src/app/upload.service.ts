import {Injectable} from '@angular/core';
import {HttpClient, HttpErrorResponse, HttpEvent, HttpEventType} from "@angular/common/http";
import {catchError, last, map, of, tap} from "rxjs";

import {MessageService} from "./message.service";

@Injectable({
  providedIn: 'root'
})
export class UploadService {

  constructor(
    private http: HttpClient,
    private messenger: MessageService
  ) { }

  upload(file: File) {
    if(!file) {
      return of("No file was provided.")
    }

    const data = new FormData();
    data.append('file', file)

    return this.http.post('/api', data, {
      reportProgress: true,
      observe: "events"
    }).pipe(
      map(event => this.getEventMessage(event, file)),
      tap(message => this.showProgress(message)),
      last(),
      catchError(this.handleError(file))
    );
  }


  private getEventMessage(event: HttpEvent<any>, file: File) {
    switch (event.type) {
      case HttpEventType.Sent:
        return `Uploading file ${file.name} of size ${file.size}.`;
        break
      case HttpEventType.UploadProgress:
        const percentDone = Math.round(100 * event.loaded / (event.total ?? 0));
        return `File ${file.name} is ${percentDone}% uploaded...`
        break
      case HttpEventType.Response:
        return `File ${file.name} was completely uploaded.`
        break
      default:
        return `File ${file.name} invoked unexpected event: ${event.type}.`
    }
  }


  private handleError(file: File) {
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

  private showProgress(message: string) {
    this.messenger.add(message);
  }
}
