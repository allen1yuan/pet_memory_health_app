// ============================================================
// HealthReminderCard —— 健康提醒卡（按状态着色：逾期红/临近琥珀/正常绿）
// entry/src/main/ets/components/HealthReminderCard.ets
// ============================================================

import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { Catalog } from '../common/Catalog'
import { DateUtil } from '../common/DateUtil'
import { HealthReminder } from '../model/PetModels'

@Component
export struct HealthReminderCard {
  @Prop reminder: HealthReminder
  @Prop actionLabel: string = ''
  onAction?: () => void
  onDone?: () => void

  private statusColor(): ResourceColor {
    return Catalog.statusColor(this.reminder.status)
  }

  private dueText(): string {
    if (this.reminder.done) return '已完成'
    return DateUtil.dueText(this.reminder.dueDate)
  }

  build() {
    Row() {
      Row({ space: 11 }) {
        // 类型图标块
        Text(Catalog.healthGlyph(this.reminder.type))
          .fontSize(18)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .borderRadius(12)
          .backgroundColor(Theme.color.bgCardElevated)
          .border({ width: 1, color: this.reminder.done ? Theme.color.borderDefault : this.statusColor() })

        Column({ space: 2 }) {
          Text(this.reminder.title.length > 0 ? this.reminder.title : Catalog.healthLabel(this.reminder.type))
            .fontSize(Theme.font.caption)
            .fontColor(Theme.color.textPrimary)
            .fontWeight(FontWeight.Medium)
          Text(this.dueText())
            .fontSize(Theme.font.footnote)
            .fontColor(this.reminder.done ? Theme.color.textTertiary : this.statusColor())
        }
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)

      if (this.reminder.done) {
        Text(Icons.check).fontSize(18).fontColor(Theme.color.success)
      } else if (this.actionLabel.length > 0) {
        Text(this.actionLabel)
          .fontSize(Theme.font.footnote)
          .fontColor(this.statusColor())
          .padding({ left: 11, right: 11, top: 7, bottom: 7 })
          .borderRadius(Theme.radius.sm)
          .backgroundColor(Theme.color.bgCard)
          .border({ width: 1, color: Theme.color.borderDefault })
          .onClick(() => { if (this.onAction) this.onAction() })
      }
    }
    .width('100%')
    .padding(13)
    .backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.color.borderDefault })
    .shadow(Theme.shadow.card)
  }
}
