import {Component, OnInit} from '@angular/core';
import {FormBuilder, FormArray} from "@angular/forms";
import {JsonResponse, UploadService} from "../upload.service";

@Component({
  selector: 'app-text-form',
  templateUrl: './text-form.component.html',
  styleUrls: ['./text-form.component.css']
})
export class TextFormComponent implements OnInit {

  jsonResponse: JsonResponse | undefined;

  keyValueForm = this.fb.group({
    keyValuePairs: this.fb.array([
      this.fb.group({
        key: [''],
        value: ['']
      })
    ])
  })

  get keyValuePairs() {
    return this.keyValueForm.get('keyValuePairs') as FormArray;
  };

  addKeyValuePair() {
    this.keyValuePairs.push(this.fb.group({
      key: [''],
      value: ['']
    }));
  }

  onSubmit() {
    let formInput: string = JSON.stringify(this.keyValueForm.value)
    if(formInput) {
      this.restructureJson(formInput)
      this.uploadService.sendJson(this.restructureJson(formInput)).subscribe(
        response => {this.jsonResponse = {...response}}
      )
      this.keyValuePairs.clear();
      this.addKeyValuePair();
    }
  }

  restructureJson(jsonString: string): String {
    let jsonObject = JSON.parse(jsonString)
    let array = [];
    for (let i = 0; i < jsonObject.keyValuePairs.length; i++) {
      let key = jsonObject.keyValuePairs[i].key;
      let value = jsonObject.keyValuePairs[i].value;
      if(!key || !value) continue;
      if(isNaN(value)) {
        array.push(`"${key}":"${value}"`)
      } else {
        array.push(`"${key}": ${value}`)
      }
    }
    let arrayString = array.join(',')
    return arrayString = `{${arrayString}}`
  }

  onReset() {
    this.keyValuePairs.clear();
    this.addKeyValuePair()
  }



  constructor(
    private fb: FormBuilder,
    private uploadService: UploadService) {
  }

  ngOnInit(): void {
  }
}
