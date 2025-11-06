import { ActivityDetector } from './ActivityDetector';
import { Activity, ActivityType } from '../common/model/Activity';
import { MediaController } from '../audio/MediaController';
import { MusicModel } from '../common/model/MusicModel';

export class ActivityMusicManager {
  private static instance: ActivityMusicManager | undefined;
  private detector: ActivityDetector;
  private activityToSongs: Map<ActivityType, MusicModel[]> = new Map<ActivityType, MusicModel[]>();
  private currentActivity: ActivityType = ActivityType.STATIONARY;

  private constructor() {
    this.detector = new ActivityDetector(true);
    const self: ActivityMusicManager = this;
    this.detector.onActivityChange((activity: Activity): void => {
      self.onActivityChange(activity);
    });
  }

  static getInstance(): ActivityMusicManager {
    if (!ActivityMusicManager.instance) {
      ActivityMusicManager.instance = new ActivityMusicManager();
    }
    return ActivityMusicManager.instance;
  }

  start(): void {
    this.detector.start();
  }

  stop(): void {
    this.detector.stop();
  }

  setActivitySongs(activity: ActivityType, songs: MusicModel[]): void {
    this.activityToSongs.set(activity, songs);
  }

  private rebuildActiveIndices(activity: ActivityType): void {
    const allSongs: MusicModel[] | undefined = AppStorage.get<MusicModel[]>('musicList');
    if (allSongs === undefined) {
      AppStorage.setOrCreate('activeIndices', [] as number[]);
      return;
    }

    const allowed: number[] = [];
    for (let i = 0; i < allSongs.length; i++) {
      const tag = allSongs[i].activityTag;
      if (activity === ActivityType.STATIONARY && tag === ActivityType.STATIONARY) {
        allowed.push(i);
      } else if (activity === ActivityType.WALKING && tag === ActivityType.WALKING) {
        allowed.push(i);
      } else if (activity === ActivityType.RUNNING && tag === ActivityType.RUNNING) {
        allowed.push(i);
      }
    }

    AppStorage.setOrCreate('activeIndices', allowed);
  }

  private onActivityChange(activity: Activity): void {
    this.currentActivity = activity.type;
    // expose activity to UI (chip)
    AppStorage.setOrCreate('currentActivity', activity.type);

    // build filtered playlist
    this.rebuildActiveIndices(activity.type);

    const allowed: number[] | undefined = AppStorage.get<number[]>('activeIndices');
    const allSongs: MusicModel[] | undefined = AppStorage.get<MusicModel[]>('musicList');
    if (allSongs === undefined || allowed === undefined) {
      return;
    }

    // nothing tagged for this activity -> do not change track
    if (allowed.length === 0) {
      return;
    }

    // if current selection isn’t allowed, jump to a random allowed one
    const currentIdx: number | undefined = AppStorage.get<number>('selectIndex');
    let currentAllowed = false;
    if (currentIdx !== undefined) {
      for (let i = 0; i < allowed.length; i++) {
        if (allowed[i] === currentIdx) {
          currentAllowed = true;
          break;
        }
      }
    }

    if (!currentAllowed) {
      const pick: number = Math.floor(Math.random() * allowed.length);
      const nextGlobalIndex: number = allowed[pick];
      MediaController.getInstance().startByIndex(nextGlobalIndex);
    }
  }
}