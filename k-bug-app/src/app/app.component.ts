import { Component } from '@angular/core';
import { LoaderService } from './loader.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  public done = true;
  public error = false;

  public rCount = 6;
  public semaphoreMode = 1; // 1 means use semaphores, 2 means do not use semaphores, 3 means mixed

  public times: Array<any> = null;

  constructor(private ldr: LoaderService) {

  }

  public begin() {
    if (this.badRange()) {
      return;
    }

    this.done = false;
    this.error = false;

    this.times = null;

    this.ldr.dbRequests(this.semaphoreMode, this.getCount()).subscribe((responses) => {
      this.done = true;
      this.times = responses;
    },
    (error) => {
      console.log('error = ', error);
      this.error = true;
      this.done = true;
    });
  }

  getCount() {
    return parseInt(this.rCount + '', 10);
  }

  formatMS(v: string): string {
    return parseInt(parseFloat(v) * 1000 + '', 10) + ' ms';
  }

  badRange(): boolean {
    const c = this.getCount();

    if (c < 1 || c > 6 || isNaN(c)) {
      return true;
    } else {
      return false;
    }
  }
}
