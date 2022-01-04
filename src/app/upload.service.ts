import { Injectable } from '@angular/core';
import { HttpClient } from "@angular/common/http";
import {Observable} from "rxjs";

@Injectable({
  providedIn: 'root'
})
export class UploadService {

  constructor(private http: HttpClient) { }

  upload(file: File): Observable<any> {
    const data = new FormData();
    data.append('file', file)
    return this.http.post('/api', data);
  }

  getAnswer(): Observable<any> {
    return this.http.get<any>("/api", {observe: 'body', responseType: 'json'})
  }
}
