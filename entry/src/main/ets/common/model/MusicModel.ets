import {ActivityType } from '../model/Activity';

export class MusicModel {
  id: number = 1;
  title: string = 'Dream It Possible';
  artist: string = 'Delacey';
  artwork: Resource = $r('app.media.ic_dream_it');
  src: string = 'dream_it_possible_delacey.mp3';
  activityTag?: ActivityType;
}