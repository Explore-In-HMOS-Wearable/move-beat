export enum ActivityType {
  STATIONARY,
  WALKING,
  RUNNING
}

export class Activity {
  type: ActivityType;
  constructor(type: ActivityType) {
    this.type = type;
  }
}
