import { MusicModel } from '../common/model/MusicModel'
import { ActivityType } from '../common/model/Activity'

@Builder
export function TagSongsPageBuilder() {
  TagSongsPage()
}

@Entry
@Component
export struct TagSongsPage {
  @State songs: MusicModel[] = []
  private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    const list: MusicModel[] | undefined = AppStorage.get<MusicModel[]>('musicList')
    if (list !== undefined) {
      this.songs = list
    }
  }

  private labels(): string[] {
    return ['None', 'Walking', 'Running', 'Stationary']
  }

  // Current tag -> picker index
  private indexOf(song: MusicModel): number {
    if (song.activityTag === undefined) return 0
    if (song.activityTag === ActivityType.WALKING) return 1
    if (song.activityTag === ActivityType.RUNNING) return 2
    return 3
  }

  // Apply picker index -> tag
  private apply(songIdx: number, pickerIdx: number): void {
    if (pickerIdx === 0) {
      this.songs[songIdx].activityTag = undefined
    } else if (pickerIdx === 1) {
      this.songs[songIdx].activityTag = ActivityType.WALKING
    } else if (pickerIdx === 2) {
      this.songs[songIdx].activityTag = ActivityType.RUNNING
    } else {
      this.songs[songIdx].activityTag = ActivityType.STATIONARY
    }
    AppStorage.setOrCreate('musicList', this.songs)
  }

  build() {
    NavDestination() {
      Column() {
        // Header (tap to go back)
        Text('Tag Songs')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin(6)
          .onClick(() => this.pathStack.pop())

        // List with large pickers for watch UX
        List() {
          ForEach(
            this.songs,
            (song: MusicModel, idx: number) => {
              ListItem() {
                Column() {
                  Text(song.title)
                    .fontSize(14)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin(4)

                  TextPicker({
                    range: this.labels(),
                    selected: this.indexOf(song)
                  })
                    .onChange((value: string | string[], index: number | number[]) => {
                      const i: number = typeof index === 'number' ? index : (index.length > 0 ? index[0] : 0)
                      this.apply(idx, i)
                    })
                    .margin(2)
                }
                .padding(8)
              }
            },
            (_: MusicModel, i: number): string => `${i}` // explicit types avoid any/unknown
          )
        }
        .layoutWeight(1)
      }
      .padding(10)   // safe padding for round watch faces
      .height('100%')
      .width('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}