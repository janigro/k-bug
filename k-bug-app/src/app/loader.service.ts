import { Injectable } from '@angular/core';
import { Observable, forkJoin } from 'rxjs';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class LoaderService {

  constructor(private http: HttpClient) {
  }

  dbRequest(semaphores: boolean, k: number): Observable<any> {
    if (semaphores) {
      return this.http.get<any>('/with_semaphores/' + k);
    } else {
      return this.http.get<any>('/without_semaphores/' + k);
    }

  }

  dbRequests(semaphores: number, requestCount: number): Observable<any> {

    const observables = new Array<Observable<any>>();

    for (let j = 0; j < requestCount; j++) {
      let s = true;

      if (semaphores === 1) {
        s = true;
      } else if (semaphores === 2) {
        s = false;
      } else {
        s = (j % 2) === 0;
      }
      observables.push(this.dbRequest(s, j));
    }

    return forkJoin(observables);
  }
}
