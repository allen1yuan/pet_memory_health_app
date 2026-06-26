// ============================================================
// ShareSheet —— 一键分享半屏内容（模板文案 + 复制/系统分享）
// entry/src/main/ets/components/ShareSheet.ets
// ============================================================

import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'

@Component
export struct ShareSheet {
  @Prop caption: string = ''
  @Prop tags: string[] = ['#宠物日记', '#养宠日常', '#毛孩子']
  @Prop thumbUris: string[] = []
  onCopy?: () => void
  onShare?: () => void

  build() {
    Column({ space: 13 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)

      Text('分享这段成长')
        .fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        .width('100%')

      // 预览卡
      Column() {
        if (this.thumbUris.length > 0) {
          Row({ space: 2 }) {
            ForEach(this.thumbUris.slice(0, 3), (u: string) => {
              Image(u).layoutWeight(1).height(90).objectFit(ImageFit.Cover)
            })
          }.width('100%')
        } else {
          Row({ space: 2 }) {
            Column().layoutWeight(1).height(90).backgroundColor('#FDE9D4')
            Column().layoutWeight(1).height(90).backgroundColor('#FAF7F3')
            Column().layoutWeight(1).height(90).backgroundColor('#FDEEDE')
          }.width('100%')
        }
        Column({ space: 8 }) {
          Text(this.caption).fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).lineHeight(21)
          Row({ space: 6 }) {
            ForEach(this.tags, (t: string) => {
              Text(t).fontSize(Theme.font.footnote).fontColor(Theme.color.primary)
                .padding({ left: 9, right: 9, top: 3, bottom: 3 })
                .backgroundColor(Theme.color.primaryDim).borderRadius(Theme.radius.pill)
            })
          }
        }.alignItems(HorizontalAlign.Start).padding(13).width('100%')
      }
      .width('100%').backgroundColor(Theme.color.bgCard)
      .borderRadius(Theme.radius.md).clip(true)
      .border({ width: 1, color: Theme.color.borderDefault })

      Text('文案为模板生成 · 复制后可自行编辑发布')
        .fontSize(Theme.font.micro).fontColor(Theme.color.textDisabled)
        .width('100%').textAlign(TextAlign.Center)

      Row({ space: 8 }) {
        Row({ space: 7 }) {
          Text(Icons.copy).fontSize(16).fontColor(Theme.color.textSecondary)
          Text('复制文案').fontSize(Theme.font.caption).fontColor(Theme.color.textSecondary)
        }
        .layoutWeight(1).height(48).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.color.borderDefault })
        .onClick(() => { if (this.onCopy) this.onCopy() })

        Row({ space: 7 }) {
          Text(Icons.share).fontSize(16).fontColor(Theme.color.textOnPrimary)
          Text('系统分享').fontSize(Theme.font.caption).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1).height(48).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.color.primary).borderRadius(Theme.radius.md)
        .onClick(() => { if (this.onShare) this.onShare() })
      }.width('100%')
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep)
    .borderRadius({ topLeft: 22, topRight: 22 })
  }
}
