// ============================================================
// MilestoneCard —— 成长里程碑卡片正文（时间轴节点的右侧卡）
// entry/src/main/ets/components/MilestoneCard.ets
// ============================================================

import { Theme } from '../common/Theme'
import { Catalog } from '../common/Catalog'
import { DateUtil } from '../common/DateUtil'
import { Milestone } from '../model/PetModels'

@Component
export struct MilestoneCard {
  @Prop milestone: Milestone
  onTap?: () => void

  build() {
    Column({ space: 6 }) {
      // 标题行：类型 chip + 标题
      Row({ space: 7 }) {
        Text(Catalog.milestoneLabel(this.milestone.type))
          .fontSize(Theme.font.footnote)
          .fontColor(Catalog.milestoneColor(this.milestone.type))
          .padding({ left: 7, right: 7, top: 2, bottom: 2 })
          .backgroundColor(Theme.color.bgCardElevated)
          .borderRadius(Theme.radius.xs)
        Text(this.milestone.title)
          .fontSize(Theme.font.caption)
          .fontColor(Theme.color.textPrimary)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')

      Text(DateUtil.monthDay(this.milestone.date) + (this.milestone.note.length > 0 ? ' · ' + this.milestone.note : ''))
        .fontSize(Theme.font.footnote)
        .fontColor(Theme.color.textTertiary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 照片缩略条（最多 3 张 + 余量）
      if (this.milestone.photoUris.length > 0) {
        Row({ space: 5 }) {
          ForEach(this.milestone.photoUris.slice(0, 3), (uri: string) => {
            Image(uri)
              .width(48).height(40)
              .objectFit(ImageFit.Cover)
              .borderRadius(5)
          })
          if (this.milestone.photoUris.length > 3) {
            Text('+' + (this.milestone.photoUris.length - 3))
              .fontSize(Theme.font.footnote)
              .fontColor(Theme.color.textTertiary)
              .width(40).height(40)
              .textAlign(TextAlign.Center)
              .borderRadius(5)
              .backgroundColor(Theme.color.bgCardElevated)
          }
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.color.borderDefault })
    .onClick(() => { if (this.onTap) this.onTap() })
  }
}
