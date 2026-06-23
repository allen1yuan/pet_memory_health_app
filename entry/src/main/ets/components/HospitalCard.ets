// ============================================================
// HospitalCard —— 宠医星医院卡（星级 + 认证标 + 操作）
// entry/src/main/ets/components/HospitalCard.ets
// ============================================================

import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { Hospital } from '../model/PetModels'

@Component
export struct HospitalCard {
  @Prop hospital: Hospital
  onOpen?: () => void
  onBook?: () => void

  @Builder stars(count: number) {
    Row({ space: 1 }) {
      ForEach([1, 2, 3], (i: number) => {
        Text(i <= count ? Icons.star : Icons.starHollow)
          .fontSize(11)
          .fontColor(count === 3 ? Theme.color.primary : Theme.color.textSecondary)
      })
    }
  }

  build() {
    Column({ space: 9 }) {
      Row() {
        Column({ space: 5 }) {
          Row({ space: 7 }) {
            Text(this.hospital.name)
              .fontSize(Theme.font.subtitle - 1)
              .fontColor(Theme.color.textPrimary)
              .fontWeight(FontWeight.Medium)
            this.stars(this.hospital.star)
          }
          Row({ space: 5 }) {
            Text(Icons.mapPin).fontSize(11).fontColor(Theme.color.textTertiary)
            Text(this.hospital.address + ' · ' + this.hospital.distanceText)
              .fontSize(Theme.font.footnote)
              .fontColor(Theme.color.textTertiary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          if (this.hospital.services.length > 0) {
            Row({ space: 5 }) {
              ForEach(this.hospital.services.slice(0, 3), (s: string) => {
                Text(s)
                  .fontSize(Theme.font.micro)
                  .fontColor(Theme.color.textTertiary)
                  .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                  .backgroundColor(Theme.color.borderDefault)
                  .borderRadius(5)
              })
            }
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.hospital.star === 3) {
          Text(Icons.hospital)
            .fontSize(20)
            .width(44)
            .height(44)
            .textAlign(TextAlign.Center)
            .borderRadius(9)
            .backgroundColor(Theme.color.primaryDim)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Divider().color(Theme.color.borderDefault)

      Row() {
        Row({ space: 5 }) {
          Text(Icons.shieldCheck).fontSize(11).fontColor(Theme.color.success)
          Text('第三方中立认证').fontSize(Theme.font.footnote).fontColor(Theme.color.success)
        }
        .padding({ left: 9, right: 9, top: 5, bottom: 5 })
        .backgroundColor('#27200F')
        .borderRadius(Theme.radius.xs)

        Blank()

        if (this.hospital.star === 3) {
          Text('申请预约')
            .fontSize(Theme.font.footnote)
            .fontColor(Theme.color.textOnPrimary)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 16, right: 16, top: 7, bottom: 7 })
            .backgroundColor(Theme.color.primary)
            .borderRadius(Theme.radius.sm)
            .onClick(() => { if (this.onBook) this.onBook() })
        } else {
          Text('查看详情')
            .fontSize(Theme.font.footnote)
            .fontColor(Theme.color.textSecondary)
            .padding({ left: 16, right: 16, top: 7, bottom: 7 })
            .backgroundColor(Theme.color.bgCard)
            .borderRadius(Theme.radius.sm)
            .border({ width: 1, color: Theme.color.borderDefault })
            .onClick(() => { if (this.onOpen) this.onOpen() })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(13)
    .backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: this.hospital.star === 3 ? '#3A2820' : Theme.color.borderDefault })
    .onClick(() => { if (this.onOpen) this.onOpen() })
  }
}
