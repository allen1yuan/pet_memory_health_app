// ============================================================
// 宠忆时光 - 成长时间轴（按年分组 + 手动记录里程碑）
// entry/src/main/ets/pages/TimelinePage.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { AppChip, MilestoneCard } from '../components'
import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { Catalog } from '../common/Catalog'
import { DateUtil } from '../common/DateUtil'
import { AppInit } from '../service/AppInit'
import { PrefStore } from '../service/PrefStore'
import { PetStore } from '../service/PetStore'
import { PhotoPickerUtil } from '../service/PhotoPickerUtil'
import { Milestone, CategoryMeta } from '../model/PetModels'

class TimelineRouteParams {
  petId: number = 0
  openAdd: boolean = false
}

@Entry
@Component
struct TimelinePage {
  @State petId: number = 0
  @State milestones: Milestone[] = []
  @State years: number[] = []
  @State showAdd: boolean = false
  @State addType: string = 'birthday'
  @State addTitle: string = ''
  @State addDate: number = 0
  @State addPhotos: string[] = []
  @State showDetail: boolean = false
  @State selectedMilestone: Milestone = new Milestone()
  private ctx: common.UIAbilityContext | null = null
  private mtypes: CategoryMeta[] = Catalog.milestoneTypes()

  async aboutToAppear(): Promise<void> {
    this.ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    await AppInit.ensure(this.ctx)
    const params = this.getUIContext().getRouter().getParams() as TimelineRouteParams
    this.petId = params && params.petId > 0 ? params.petId : PrefStore.currentPetId()
    await this.reload()
    if (params && params.openAdd) {
      this.showAdd = true
    }
  }

  private async reload(): Promise<void> {
    const list = await PetStore.listMilestones(this.petId)
    this.milestones = list
    const ys: number[] = []
    for (let i = 0; i < list.length; i++) {
      const y: number = DateUtil.year(list[i].date)
      if (!ys.includes(y)) ys.push(y)
    }
    this.years = ys
  }

  private toast(msg: string): void { promptAction.showToast({ message: msg, duration: 1500 }) }

  private inYear(y: number): Milestone[] {
    return this.milestones.filter((m: Milestone) => DateUtil.year(m.date) === y)
  }

  private pickDate(): void {
    this.getUIContext().showDatePickerDialog({
      start: new Date('2005-1-1'),
      end: new Date(),
      selected: this.addDate > 0 ? new Date(this.addDate) : new Date(),
      onDateAccept: (d: Date): void => { this.addDate = d.getTime() }
    })
  }

  private async pickPhotos(): Promise<void> {
    if (!this.ctx) return
    const uris: string[] = await PhotoPickerUtil.pickAndStore(this.ctx, 9)
    if (uris.length > 0) this.addPhotos = this.addPhotos.concat(uris)
  }

  private async saveMilestone(): Promise<void> {
    if (this.addTitle.trim().length === 0) { this.toast('请填写标题'); return }
    const m = new Milestone()
    m.petId = this.petId
    m.type = this.addType
    m.title = this.addTitle.trim()
    m.date = this.addDate > 0 ? this.addDate : Date.now()
    m.note = ''
    m.photoUris = this.addPhotos
    await PetStore.insertMilestone(m)
    this.showAdd = false
    this.addTitle = ''; this.addPhotos = []; this.addDate = 0; this.addType = 'birthday'
    await this.reload()
    this.toast('里程碑已保存')
  }

  private openMilestone(m: Milestone): void {
    this.selectedMilestone = m
    this.showDetail = true
  }

  private async deleteSelectedMilestone(): Promise<void> {
    if (this.selectedMilestone.id <= 0) return
    await PetStore.deleteMilestone(this.selectedMilestone.id)
    this.showDetail = false
    this.selectedMilestone = new Milestone()
    await this.reload()
    this.toast('里程碑已删除')
  }

  private async addPhotosToSelected(): Promise<void> {
    if (!this.ctx || this.selectedMilestone.id <= 0) return
    const uris: string[] = await PhotoPickerUtil.pickAndStore(this.ctx, 6)
    if (uris.length === 0) return
    const next = new Milestone()
    next.id = this.selectedMilestone.id
    next.petId = this.selectedMilestone.petId
    next.type = this.selectedMilestone.type
    next.title = this.selectedMilestone.title
    next.date = this.selectedMilestone.date
    next.note = this.selectedMilestone.note
    next.photoUris = this.selectedMilestone.photoUris.concat(uris)
    await PetStore.deleteMilestone(this.selectedMilestone.id)
    const newId: number = await PetStore.insertMilestone(next)
    next.id = newId
    this.selectedMilestone = next
    await this.reload()
    this.toast('照片已添加到里程碑')
  }

  @Builder timelineNode(m: Milestone) {
    Row({ space: 9 }) {
      Column() {
        Circle({ width: 11, height: 11 }).fill(Catalog.milestoneColor(m.type)).margin({ top: 14 })
      }.width(11)
      Column() {
        MilestoneCard({ milestone: m, onTap: (): void => this.openMilestone(m) })
      }.layoutWeight(1)
    }
    .width('100%').alignItems(VerticalAlign.Top).margin({ bottom: 8 })
  }

  @Builder addSheet() {
    Column({ space: 13 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('记录里程碑').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')

      Text('类型').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.mtypes, (t: CategoryMeta) => {
          Row() {
            AppChip({ label: t.label, leadingGlyph: Catalog.milestoneGlyph(t.key),
              selected: this.addType === t.key, onTap: (): void => { this.addType = t.key } })
          }.margin({ right: 8, bottom: 8 })
        })
      }.width('100%')

      TextInput({ placeholder: '标题，如：2岁生日快乐', text: this.addTitle })
        .height(48).backgroundColor(Theme.color.bgInput).borderRadius(Theme.radius.input)
        .padding({ left: 14, right: 14 }).fontColor(Theme.color.textPrimary)
        .placeholderColor(Theme.color.textTertiary)
        .border({ width: 1, color: Theme.color.borderDefault })
        .onChange((v: string) => { this.addTitle = v })

      Row() {
        Text(Icons.calendar).fontSize(16).fontColor(Theme.color.textTertiary)
        Text(this.addDate > 0 ? DateUtil.ymd(this.addDate) : '选择日期（默认今天）')
          .fontSize(Theme.font.caption).fontColor(this.addDate > 0 ? Theme.color.textPrimary : Theme.color.textTertiary)
          .margin({ left: 9 }).layoutWeight(1)
      }
      .width('100%').height(48).padding({ left: 14, right: 14 })
      .backgroundColor(Theme.color.bgInput).borderRadius(Theme.radius.input)
      .border({ width: 1, color: Theme.color.borderDefault })
      .onClick(() => this.pickDate())

      Text('照片').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).width('100%')
      Row({ space: 6 }) {
        ForEach(this.addPhotos.slice(0, 4), (u: string) => {
          Image(u).width(56).height(56).borderRadius(8).objectFit(ImageFit.Cover)
        })
        Column() {
          Text(Icons.plus).fontSize(20).fontColor(Theme.color.textTertiary)
        }
        .width(56).height(56).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.color.bgCard).borderRadius(8)
        .border({ width: 1, color: Theme.color.borderDefault })
        .onClick(() => this.pickPhotos())
      }.width('100%')

      Text('保存里程碑').fontSize(Theme.font.body).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
        .width('100%').height(48).textAlign(TextAlign.Center)
        .backgroundColor(Theme.color.primary).borderRadius(Theme.radius.md)
        .onClick(() => this.saveMilestone())
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  @Builder detailSheet() {
    Column({ space: 13 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Row() {
        Text(Catalog.milestoneGlyph(this.selectedMilestone.type)).fontSize(22)
        Column({ space: 2 }) {
          Text(this.selectedMilestone.title).fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
          Text(Catalog.milestoneLabel(this.selectedMilestone.type) + ' · ' + DateUtil.ymd(this.selectedMilestone.date))
            .fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
        }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 10 })
      }.width('100%')

      if (this.selectedMilestone.note.length > 0) {
        Text(this.selectedMilestone.note).fontSize(Theme.font.caption).fontColor(Theme.color.textSecondary).width('100%')
      }

      if (this.selectedMilestone.photoUris.length > 0) {
        Row({ space: 6 }) {
          ForEach(this.selectedMilestone.photoUris.slice(0, 4), (u: string) => {
            Image(u).width(58).height(58).borderRadius(8).objectFit(ImageFit.Cover)
          })
        }.width('100%')
      }

      Row({ space: 8 }) {
        Text(Icons.photoPlus).fontSize(16).fontColor(Theme.color.primary)
        Text('添加照片').fontSize(Theme.font.caption).fontColor(Theme.color.primary)
      }
      .width('100%').height(44).justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.color.primaryDim).borderRadius(Theme.radius.md)
      .border({ width: 1, color: Theme.color.borderActive })
      .onClick(() => this.addPhotosToSelected())

      Text('删除这条里程碑')
        .fontSize(Theme.font.caption).fontColor(Theme.color.error)
        .width('100%').height(44).textAlign(TextAlign.Center)
        .backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.color.borderDefault })
        .onClick(() => this.deleteSelectedMilestone())
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Row({ space: 7 }) {
          Text(Icons.back).fontSize(24).fontColor(Theme.color.textTertiary)
            .onClick(() => this.getUIContext().getRouter().back())
          Text('成长记录').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        }
        Blank()
        Row({ space: 5 }) {
          Text(Icons.plus).fontSize(14).fontColor(Theme.color.primary)
          Text('记录').fontSize(Theme.font.footnote).fontColor(Theme.color.primary)
        }
        .padding({ left: 13, right: 13, top: 5, bottom: 5 })
        .backgroundColor(Theme.color.primaryDim).borderRadius(Theme.radius.pill)
        .border({ width: 1, color: Theme.color.borderActive })
        .onClick(() => { this.showAdd = true })
      }
      .width('100%').height(44).alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 8 }) {
          if (this.milestones.length === 0) {
            Text('还没有里程碑，点「记录」添加第一条吧')
              .fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
              .width('100%').textAlign(TextAlign.Center).padding({ top: 60 })
          }
          ForEach(this.years, (y: number) => {
            Text(y.toString()).fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
              .fontWeight(FontWeight.Medium).width('100%').margin({ top: 6, bottom: 2 })
            ForEach(this.inYear(y), (m: Milestone) => { this.timelineNode(m) })
          })
          Column().height(12)
        }.width('100%')
      }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
    }
    .width('100%').height('100%')
    .padding({ left: 16, right: 16, top: 36 })
    .backgroundColor(Theme.color.bgBase)
    .bindSheet($$this.showAdd, this.addSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showAdd = false }
    })
    .bindSheet($$this.showDetail, this.detailSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showDetail = false }
    })
  }
}
