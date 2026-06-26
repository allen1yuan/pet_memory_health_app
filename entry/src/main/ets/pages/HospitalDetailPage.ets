// ============================================================
// 宠忆时光 - 医院详情（认证信息 + 服务 + 评价 + 申请预约）
// entry/src/main/ets/pages/HospitalDetailPage.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { HospitalRepo } from '../service/HospitalRepo'
import { Hospital, Review } from '../model/PetModels'

class HospitalDetailRouteParams {
  hospitalId: string = ''
}

@Entry
@Component
struct HospitalDetailPage {
  @State hospital: Hospital = new Hospital()
  @State booked: boolean = false

  async aboutToAppear(): Promise<void> {
    const ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    await HospitalRepo.load(ctx)
    const params = this.getUIContext().getRouter().getParams() as HospitalDetailRouteParams
    const id: string = params && params.hospitalId ? params.hospitalId : ''
    const h = HospitalRepo.byId(id)
    if (h) this.hospital = h
  }

  private toast(msg: string): void { promptAction.showToast({ message: msg, duration: 1600 }) }

  private book(): void {
    this.booked = true
    this.toast('预约请求已提交，待医院电话确认')
  }

  @Builder kv(k: string, v: string) {
    Row() {
      Text(k).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
      Blank()
      Text(v).fontSize(Theme.font.footnote).fontColor(Theme.color.textSecondary)
    }.width('100%')
  }

  @Builder stars(count: number) {
    Row({ space: 1 }) {
      ForEach([1, 2, 3], (i: number) => {
        Text(i <= count ? Icons.star : Icons.starHollow)
          .fontSize(13).fontColor(count === 3 ? Theme.color.primary : Theme.color.textSecondary)
      })
    }
  }

  build() {
    Column() {
      Row({ space: 7 }) {
        Text(Icons.back).fontSize(24).fontColor(Theme.color.textTertiary)
          .onClick(() => this.getUIContext().getRouter().back())
        Text('医院详情').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
      }.width('100%').height(44).alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 14 }) {
          // 头图
          Stack() {
            Column().width('100%').height('100%')
              .linearGradient({ angle: 160, colors: [['#FFF1DE', 0], ['#FFFFFF', 1]] })
            Column()
              .width(140).height(140).borderRadius(70)
              .backgroundColor(Theme.color.glowPrimarySm)
              .blur(40)
              .position({ x: '65%', y: -30 })
            Text(Icons.hospital).fontSize(48).fontColor(Theme.color.primary)
          }
          .width('100%').height(124).alignContent(Alignment.Center)
          .borderRadius(Theme.radius.lg).clip(true)
          .border({ width: 1, color: Theme.color.borderDefault })
          .shadow(Theme.shadow.card)

          Column({ space: 5 }) {
            Row({ space: 8 }) {
              Text(this.hospital.name).fontSize(Theme.font.h3).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
              this.stars(this.hospital.star)
            }
            Row({ space: 5 }) {
              Text(Icons.mapPin).fontSize(12).fontColor(Theme.color.textTertiary)
              Text(this.hospital.address + ' · ' + this.hospital.distanceText)
                .fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
            }
          }.alignItems(HorizontalAlign.Start).width('100%')

          // 认证块
          Column({ space: 8 }) {
            Row({ space: 7 }) {
              Text(Icons.shieldCheck).fontSize(16).fontColor(Theme.color.success)
              Text('宠医星' + (this.hospital.star === 3 ? '三星' : this.hospital.star === 2 ? '二星' : '一星') + '认证')
                .fontSize(Theme.font.caption).fontColor(Theme.color.success).fontWeight(FontWeight.Medium)
            }
            this.kv('认证等级', this.hospital.certLevel)
            this.kv('有效期至', this.hospital.certValidUntil)
            this.kv('认证方式', this.hospital.certMethod)
          }
          .width('100%').padding(12).backgroundColor('#EAF7EE')
          .borderRadius(Theme.radius.md).border({ width: 1, color: '#CDE9D3' })
          .shadow(Theme.shadow.card)

          // 服务项目
          Column({ space: 8 }) {
            Text('服务项目').fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.hospital.services, (s: string) => {
                Row() {
                  Text(s).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
                    .padding({ left: 9, right: 9, top: 4, bottom: 4 })
                    .backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.xs)
                }.margin({ right: 6, bottom: 6 })
              })
            }.width('100%')
          }.width('100%')

          // 评价
          Column({ space: 8 }) {
            Text('用户真实评价').fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
            ForEach(this.hospital.reviews, (rv: Review) => {
              Column({ space: 5 }) {
                Row({ space: 7 }) {
                  Text(rv.author.substring(0, 1)).fontSize(Theme.font.footnote).fontColor(Theme.color.primary)
                    .width(24).height(24).textAlign(TextAlign.Center).borderRadius(12).backgroundColor(Theme.color.primaryDim)
                  Text(rv.author).fontSize(Theme.font.footnote).fontColor(Theme.color.textSecondary)
                }
                Text(rv.content).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).lineHeight(19)
              }
              .width('100%').padding(11).backgroundColor(Theme.color.bgCard)
              .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
              .shadow(Theme.shadow.card)
              .alignItems(HorizontalAlign.Start)
            })
          }.width('100%')

          Row({ space: 7 }) {
            Text(this.booked ? Icons.check : Icons.calendar).fontSize(18).fontColor(Theme.color.textOnPrimary)
            Text(this.booked ? '已提交预约' : '申请预约').fontSize(Theme.font.body).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
          }
          .width('100%').height(50).justifyContent(FlexAlign.Center)
          .backgroundColor(this.booked ? Theme.color.success : Theme.color.primary).borderRadius(Theme.radius.md)
          .shadow(Theme.shadow.buttonAmber)
          .onClick(() => this.book())

          Text('提交后由医院电话确认具体时间')
            .fontSize(Theme.font.micro).fontColor(Theme.color.textDisabled)
            .width('100%').textAlign(TextAlign.Center).margin({ bottom: 20 })
        }.width('100%')
      }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
    }
    .width('100%').height('100%')
    .padding({ left: 16, right: 16, top: 36 })
    .backgroundColor(Theme.color.bgBase)
  }
}
