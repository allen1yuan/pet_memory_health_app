// ============================================================
// 宠忆时光 - 首页 Tab
// entry/src/main/ets/pages/tabs/HomeTab.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { PetAvatar, QuickActionTile } from '../../components'
import { Theme } from '../../common/Theme'
import { Icons } from '../../common/Icons'
import { AppConstants } from '../../common/Constants'
import { Catalog } from '../../common/Catalog'
import { DateUtil } from '../../common/DateUtil'
import { AppInit } from '../../service/AppInit'
import { PrefStore } from '../../service/PrefStore'
import { PetStore } from '../../service/PetStore'
import { SeedData } from '../../service/SeedData'
import { Pet, Milestone, HealthReminder } from '../../model/PetModels'

const TAG: string = 'ChongYiHome'
const DOMAIN: number = 0xFF00

class TimelineRouteParams {
  petId: number = 0
  openAdd: boolean = false
}

@Component
export struct HomeTab {
  @Prop @Watch('onTick') tick: number = 0
  switchTab?: (i: number) => void

  @State pets: Pet[] = []
  @State current: Pet = new Pet()
  @State reminders: HealthReminder[] = []
  @State recent: Milestone[] = []
  @State showNotifications: boolean = false

  async aboutToAppear(): Promise<void> {
    const ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    await AppInit.ensure(ctx)
    await this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private async reload(): Promise<void> {
    try {
      let pets = await PetStore.listPets()
      hilog.info(DOMAIN, TAG, 'reload: existing pets=' + pets.length)
      if (pets.length === 0) {
        // 兜底：无论从何种路径进入首页，保证至少有一份本地演示数据，避免空白页
        const seededId: number = await SeedData.seedDemoIfEmpty()
        hilog.info(DOMAIN, TAG, 'reload: seeded demo pet id=' + seededId)
        pets = await PetStore.listPets()
        hilog.info(DOMAIN, TAG, 'reload: pets after seeding=' + pets.length)
      }
      this.pets = pets
      if (pets.length === 0) {
        hilog.error(DOMAIN, TAG, 'reload: still zero pets after seeding attempt')
        return
      }
      let curId: number = PrefStore.currentPetId()
      let cur: Pet = pets[0]
      for (let i = 0; i < pets.length; i++) {
        if (pets[i].id === curId) cur = pets[i]
      }
      this.current = cur
      PrefStore.setCurrentPetId(cur.id)
      this.reminders = await PetStore.listHealth(cur.id)
      this.recent = await PetStore.listMilestones(cur.id)
      hilog.info(DOMAIN, TAG, 'reload: done, current=' + cur.name + ' reminders=' + this.reminders.length + ' milestones=' + this.recent.length)
    } catch (e) {
      const detail: string = e instanceof Error ? e.message : JSON.stringify(e)
      hilog.error(DOMAIN, TAG, 'reload failed: ' + detail)
      this.toast('加载首页数据失败：' + detail)
    }
  }

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: 1500 })
  }

  private companionDays(): number {
    if (this.current.createdAt <= 0) return 1
    return DateUtil.daysSince(this.current.createdAt) + 1
  }

  private nearest(): HealthReminder | null {
    for (let i = 0; i < this.reminders.length; i++) {
      if (!this.reminders[i].done) return this.reminders[i]
    }
    return null
  }

  private gotoTimeline(openAdd: boolean): void {
    const params = new TimelineRouteParams()
    params.petId = this.current.id
    params.openAdd = openAdd
    this.getUIContext().getRouter().pushUrl({
      url: AppConstants.PAGE_TIMELINE,
      params: params
    })
  }

  private gotoHospital(): void {
    this.getUIContext().getRouter().pushUrl({ url: AppConstants.PAGE_HOSPITAL })
  }

  private gotoSetup(): void {
    this.getUIContext().getRouter().pushUrl({ url: AppConstants.PAGE_PET_SETUP })
  }

  @Builder topBar() {
    Row() {
      Row({ space: 7 }) {
        Text(Icons.paw).fontSize(18).fontColor(Theme.color.primary)
        Text('宠忆时光').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
      }
      Blank()
      Stack() {
        Text(Icons.bell).fontSize(20).fontColor(Theme.color.textTertiary)
        if (this.pendingReminderCount() > 0) {
          Circle({ width: 8, height: 8 }).fill(Theme.color.primary).offset({ x: 8, y: -8 })
        }
      }.onClick(() => { this.showNotifications = true })
    }
    .width('100%').height(40).alignItems(VerticalAlign.Center)
  }

  private pendingReminderCount(): number {
    let n: number = 0
    for (let i = 0; i < this.reminders.length; i++) {
      if (!this.reminders[i].done) n += 1
    }
    return n
  }

  @Builder notificationSheet() {
    Column({ space: 12 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('提醒中心').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
      if (this.pendingReminderCount() === 0) {
        Text('暂无待处理提醒').fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
          .width('100%').textAlign(TextAlign.Center).padding({ top: 20, bottom: 20 })
      }
      ForEach(this.reminders, (r: HealthReminder) => {
        if (!r.done) {
          Row() {
            Text(Catalog.healthGlyph(r.type)).fontSize(18).fontColor(Theme.color.primary)
            Column({ space: 2 }) {
              Text(r.title).fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
              Text(DateUtil.dueText(r.dueDate) + ' · ' + Catalog.healthLabel(r.type))
                .fontSize(Theme.font.footnote).fontColor(Catalog.statusColor(r.status))
            }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 10 })
          }
          .width('100%').padding(12).backgroundColor(Theme.color.bgCard)
          .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
          .onClick(() => {
            this.showNotifications = false
            if (this.switchTab) this.switchTab(2)
          })
        }
      })
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  @Builder petSelector() {
    Row({ space: 14 }) {
      ForEach(this.pets, (p: Pet) => {
        PetAvatar({
          name: p.name, species: p.species, avatarUri: p.avatarUri,
          active: p.id === this.current.id,
          onTap: (): void => {
            PrefStore.setCurrentPetId(p.id)
            this.current = p
            this.reload()
          }
        })
      })
      Column({ space: 5 }) {
        Text(Icons.plus).fontSize(22).fontColor(Theme.color.textDisabled)
          .width(52).height(52).textAlign(TextAlign.Center)
          .borderRadius(26).backgroundColor(Theme.color.bgCard)
          .border({ width: 2, color: Theme.color.borderDefault })
        Text('添加').fontSize(Theme.font.footnote).fontColor(Theme.color.textDisabled)
      }.onClick(() => this.gotoSetup())
    }
    .width('100%')
  }

  @Builder heroCard() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column().width('100%').height('100%')
        .linearGradient({ angle: 160, colors: [[Theme.color.primaryLight, 0], [Theme.color.primary, 1]] })
      Column()
        .width(140).height(140).borderRadius(70)
        .backgroundColor('#33FFFFFF')
        .blur(40)
        .position({ x: '70%', y: -40 })
      Column({ space: 5 }) {
        Text('今日瞬间').fontSize(Theme.font.footnote).fontColor(Theme.color.textOnPrimary)
          .padding({ left: 9, right: 9, top: 3, bottom: 3 })
          .backgroundColor('#33FFFFFF').borderRadius(Theme.radius.xs)
        Text('陪伴 ' + this.current.name + ' 的第 ' + this.companionDays() + ' 天')
          .fontSize(Theme.font.subtitle).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
        Text('点击查看成长时间轴 →').fontSize(Theme.font.footnote).fontColor('#FFF1DE')
      }
      .alignItems(HorizontalAlign.Start).padding(16)
    }
    .width('100%').height(144).borderRadius(Theme.radius.lg).clip(true)
    .shadow(Theme.shadow.buttonAmber)
    .onClick(() => this.gotoTimeline(false))
  }

  @Builder quickActions() {
    Row({ space: 9 }) {
      QuickActionTile({ glyph: Icons.camera, label: '记录瞬间', glyphColor: Theme.color.primary,
        onTap: (): void => { if (this.switchTab) this.switchTab(1) } })
      QuickActionTile({ glyph: Icons.flag, label: '加里程碑', glyphColor: Theme.color.accent,
        onTap: (): void => this.gotoTimeline(true) })
      QuickActionTile({ glyph: Icons.stethoscope, label: '健康提醒', glyphColor: Theme.color.success,
        onTap: (): void => { if (this.switchTab) this.switchTab(2) } })
      QuickActionTile({ glyph: Icons.hospital, label: '找医院', glyphColor: Theme.color.info,
        onTap: (): void => this.gotoHospital() })
    }
    .width('100%')
  }

  @Builder reminderStrip() {
    if (this.nearest() != null) {
      Row({ space: 8 }) {
        Circle({ width: 9, height: 9 }).fill(Theme.color.primary)
        Column({ space: 1 }) {
          Text(this.nearest()!.title).fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
          Text(DateUtil.dueText(this.nearest()!.dueDate) + ' · ' + Catalog.healthLabel(this.nearest()!.type))
            .fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        Text('查看 →').fontSize(Theme.font.footnote).fontColor(Theme.color.primary)
      }
      .width('100%').padding({ left: 13, right: 13, top: 11, bottom: 11 })
      .backgroundColor(Theme.color.primaryDim).borderRadius(Theme.radius.sm)
      .border({ width: 1, color: Theme.color.borderActive })
      .shadow(Theme.shadow.card)
      .onClick(() => { if (this.switchTab) this.switchTab(2) })
    }
  }

  @Builder recentMilestone() {
    if (this.recent.length > 0) {
      Row() {
        Text('最近里程碑').fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        Blank()
        Text('查看全部').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
          .onClick(() => this.gotoTimeline(false))
      }.width('100%').margin({ top: 2 })

      Row({ space: 10 }) {
        Text(Catalog.milestoneGlyph(this.recent[0].type)).fontSize(18)
          .width(38).height(38).textAlign(TextAlign.Center).borderRadius(11)
          .backgroundColor(Theme.color.primaryDim)
          .border({ width: 1, color: Theme.color.borderActive })
        Column({ space: 1 }) {
          Text(this.recent[0].title).fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
          Text(DateUtil.monthDay(this.recent[0].date)).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        Text(Icons.chevronRight).fontSize(18).fontColor(Theme.color.textDisabled)
      }
      .width('100%').padding(13).backgroundColor(Theme.color.bgCard)
      .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
      .shadow(Theme.shadow.card)
      .onClick(() => this.gotoTimeline(false))
    }
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        this.topBar()
        this.petSelector()
        this.heroCard()
        this.quickActions()
        this.reminderStrip()
        this.recentMilestone()
        Column().height(12)
      }
      .width('100%').padding({ left: 16, right: 16 })
    }
    .width('100%').height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .padding({ top: 36 })
    .backgroundColor(Theme.color.bgBase)
    .bindSheet($$this.showNotifications, this.notificationSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showNotifications = false }
    })
  }
}
