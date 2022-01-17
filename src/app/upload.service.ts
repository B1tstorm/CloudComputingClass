import {Injectable} from '@angular/core';
import {HttpClient, HttpErrorResponse, HttpEvent, HttpEventType, HttpHeaders} from "@angular/common/http";
import {catchError, last, map, Observable, of, tap, throwError} from "rxjs";

import {environment} from "../environments/environment";

export interface JsonResponse {
  status: string,
  message: string,
  clientId: number,
  data: object
}

@Injectable({
  providedIn: 'root'
})
export class UploadService {

  constructor(
    private http: HttpClient,
  ) {
  }

  uploadFile(file: File): Observable<JsonResponse> {
    if (!file) {
      console.error("upload service produced error")
      return new Observable<JsonResponse>();
    }

    const data = new FormData();
    data.append('file', file)

    return this.http.post<JsonResponse>(environment.NODE_API_URL + '/api/file', data)
      .pipe(catchError(this.handleError));
  }

  sendJson(jsonString: String): Observable<JsonResponse> {
    if (!jsonString) {
      console.error("No jsonString provided")
      return new Observable<JsonResponse>();
    }

    const httpHeaders = new HttpHeaders()
      .set('content-type', 'application/json');

    return this.http.post<JsonResponse>(environment.NODE_API_URL + '/api/file', jsonString, {
      headers: httpHeaders
    })
      .pipe(catchError(this.handleError))
  }

  private handleJsonError(string: String) {
    return (error: HttpErrorResponse) => {
      return of("Error handling the POST request")
    }
  }

  private handleError(error: HttpErrorResponse) {
    if(error.status === 0) {
      console.error("An error occured", error.error);
    } else {
      console.error(`Backend returned code: ${error.status}. Body was: `, error.error)
    }
    return throwError("Something bad happened, please try again later.")
  }

}
