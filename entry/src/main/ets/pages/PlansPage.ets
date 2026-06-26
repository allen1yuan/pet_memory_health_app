// ============================================================
// 宠忆时光 - 会员方案（只读预览，Beta 免费）
// entry/src/main/ets/pages/PlansPage.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { AppConstants } from '../common/Constants'
import { AppInit } from '../service/AppInit'
import { PrefStore } from '../service/PrefStore'
import { PlanItem } from '../model/PetModels'

@Entry
@Component
struct PlansPage {
  @State selectedPlan: string = '免费版'

  private plans: PlanItem[] = [
    PlansPage.mk('免费版', '¥0', '基础记录 · 当前可用', false, false),
    PlansPage.mk('月卡', '¥29 / 月', '无限记录 · 全功能解锁', false, false),
    PlansPage.mk('年卡', '¥299 / 年', '折合 ¥24.9/月 · 医院9折', false, true),
    PlansPage.mk('3年卡', '¥599 / 3年', '折合 ¥16.6/月 · 最高权益', false, false)
  ]

  async aboutToAppear(): Promise<void> {
    const ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    await AppInit.ensure(ctx)
    this.selectedPlan = PrefStore.getString(AppConstants.KEY_PLAN_NAME, '免费版')
  }

  static mk(name: string, price: string, desc: string, current: boolean, recommended: boolean): PlanItem {
    const p = new PlanItem()
    p.name = name; p.price = price; p.desc = desc; p.current = current; p.recommended = recommended
    return p
  }

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: 1500 })
  }

  private selectPlan(plan: PlanItem): void {
    this.selectedPlan = plan.name
    PrefStore.setString(AppConstants.KEY_PLAN_NAME, plan.name)
    this.toast('已选择' + plan.name + '（本地演示）')
  }

  @Builder planRow(plan: PlanItem) {
    Row() {
      Column({ space: 4 }) {
        Row({ space: 7 }) {
          Text(plan.name).fontSize(Theme.font.caption)
            .fontColor(plan.recommended ? Theme.color.primary : Theme.color.textPrimary).fontWeight(FontWeight.Medium)
          if (plan.recommended) {
            Text('推荐').fontSize(Theme.font.micro).fontColor(Theme.color.textOnPrimary)
              .padding({ left: 7, right: 7, top: 1, bottom: 1 })
              .backgroundColor(Theme.color.primary).borderRadius(Theme.radius.pill)
          }
          if (plan.name === this.selectedPlan) {
            Text('当前').fontSize(Theme.font.micro).fontColor(Theme.color.success)
              .padding({ left: 7, right: 7, top: 1, bottom: 1 })
              .backgroundColor('#EAF7EE').borderRadius(Theme.radius.pill)
          }
        }
        Text(plan.desc).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text(plan.price).fontSize(Theme.font.subtitle)
        .fontColor(plan.recommended ? Theme.color.primary : Theme.color.textPrimary).fontWeight(FontWeight.Medium)
    }
    .width('100%').padding(13)
    .linearGradient(plan.recommended
      ? { angle: 135, colors: [['#FFF1DE', 0], ['#FFFFFF', 1]] }
      : { angle: 135, colors: [[Theme.color.bgCard, 0], [Theme.color.bgCard, 1]] })
    .borderRadius(Theme.radius.md)
    .border({ width: plan.recommended ? 2 : 1, color: plan.recommended ? Theme.color.primary : Theme.color.borderDefault })
    .shadow(plan.recommended ? Theme.shadow.buttonAmber : Theme.shadow.card)
    .onClick(() => this.selectPlan(plan))
  }

  build() {
    Column() {
      Row({ space: 7 }) {
        Text(Icons.back).fontSize(24).fontColor(Theme.color.textTertiary)
          .onClick(() => this.getUIContext().getRouter().back())
        Text('会员方案').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
      }.width('100%').height(44).alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text(Icons.gift).fontSize(18).fontColor(Theme.color.primary)
            Text('Beta 期间全部功能免费 · 当前为本地方案演示')
              .fontSize(Theme.font.footnote).fontColor(Theme.color.textSecondary).layoutWeight(1)
          }
          .width('100%').padding({ left: 13, right: 13, top: 11, bottom: 11 })
          .backgroundColor(Theme.color.primaryDim).borderRadius(Theme.radius.sm)
          .border({ width: 1, color: Theme.color.borderActive })
          .shadow(Theme.shadow.card)

          ForEach(this.plans, (p: PlanItem) => { this.planRow(p) })

          Text('点击任意方案即可切换当前本地会员状态')
            .fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
            .width('100%').height(50).textAlign(TextAlign.Center)
            .backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.md)

          Text('当前选择：' + this.selectedPlan + ' · 数据仅保存在本机')
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
