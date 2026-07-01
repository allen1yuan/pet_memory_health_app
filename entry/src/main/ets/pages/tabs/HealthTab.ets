// ============================================================
// 宠忆时光 - 健康 Tab（提醒 + 体重趋势 + 新增）
// entry/src/main/ets/pages/tabs/HealthTab.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { AppChip, HealthReminderCard } from '../../components'
import { Theme } from '../../common/Theme'
import { Icons } from '../../common/Icons'
import { Catalog } from '../../common/Catalog'
import { DateUtil } from '../../common/DateUtil'
import { AppConstants } from '../../common/Constants'
import { PrefStore } from '../../service/PrefStore'
import { PetStore } from '../../service/PetStore'
import { Pet, Milestone, HealthReminder, WeightEntry, CategoryMeta } from '../../model/PetModels'

@Component
export struct HealthTab {
  @Prop @Watch('onTick') tick: number = 0

  @State petId: number = 0
  @State subTab: number = 0
  @State reminders: HealthReminder[] = []
  @State weights: WeightEntry[] = []
  @State records: Milestone[] = []
  @State pet: Pet = new Pet()
  @State showAdd: boolean = false
  @State showWeight: boolean = false
  @State addType: string = 'vaccine'
  @State addDate: number = 0
  @State addCycle: number = 6
  @State addNotify: boolean = true
  @State weightText: string = ''
  @State weightDate: number = 0
  private healthTypes: CategoryMeta[] = Catalog.healthTypes()

  async aboutToAppear(): Promise<void> {
    await this.reload()
  }
  onTick(): void { this.reload() }

  private async reload(): Promise<void> {
    this.petId = PrefStore.currentPetId()
    const pet: Pet | null = await PetStore.getPet(this.petId)
    this.pet = pet ? pet : new Pet()
    this.reminders = await PetStore.listHealth(this.petId)
    this.weights = await PetStore.listWeights(this.petId)
    const milestones: Milestone[] = await PetStore.listMilestones(this.petId)
    const records: Milestone[] = []
    for (let i = 0; i < milestones.length; i++) {
      if (milestones[i].type === 'vaccine' || milestones[i].type === 'checkup') {
        records.push(milestones[i])
      }
    }
    this.records = records
  }

  private toast(msg: string): void { promptAction.showToast({ message: msg, duration: 1500 }) }

  private gotoHospital(): void {
    this.getUIContext().getRouter().pushUrl({ url: AppConstants.PAGE_HOSPITAL })
  }

  private pickDate(): void {
    this.getUIContext().showDatePickerDialog({
      start: new Date('2020-1-1'),
      end: new Date('2030-12-31'),
      selected: this.addDate > 0 ? new Date(this.addDate) : new Date(),
      onDateAccept: (d: Date): void => { this.addDate = d.getTime() }
    })
  }

  private async saveHealth(): Promise<void> {
    const h = new HealthReminder()
    h.petId = this.petId
    h.type = this.addType
    h.title = Catalog.healthLabel(this.addType)
    h.dueDate = this.addDate > 0 ? this.addDate : Date.now() + this.addCycle * 30 * AppConstants.DAY_MS
    h.cycleMonths = this.addCycle
    h.notify = this.addNotify
    h.done = false
    await PetStore.insertHealth(h)
    this.showAdd = false
    await this.reload()
    this.toast('已添加，将按期提醒')
  }

  private async markDone(reminder: HealthReminder): Promise<void> {
    await PetStore.markHealthDone(reminder.id)
    if (reminder.cycleMonths > 0) {
      const next = new HealthReminder()
      next.petId = reminder.petId
      next.type = reminder.type
      next.title = reminder.title
      next.dueDate = DateUtil.addMonths(reminder.dueDate > Date.now() ? reminder.dueDate : Date.now(), reminder.cycleMonths)
      next.cycleMonths = reminder.cycleMonths
      next.notify = reminder.notify
      next.done = false
      await PetStore.insertHealth(next)
    }
    await this.reload()
    this.toast('已完成，并生成下次提醒')
  }

  private async saveWeight(): Promise<void> {
    const v: number = parseFloat(this.weightText)
    if (v !== v || v <= 0) {
      this.toast('请输入有效体重')
      return
    }
    const w = new WeightEntry()
    w.petId = this.petId
    w.weightKg = v
    w.recordedAt = this.weightDate > 0 ? this.weightDate : Date.now()
    await PetStore.insertWeight(w)
    this.weightText = ''
    this.weightDate = 0
    this.showWeight = false
    await this.reload()
    this.toast('体重已保存')
  }

  private pickWeightDate(): void {
    this.getUIContext().showDatePickerDialog({
      start: new Date('2020-1-1'),
      end: new Date(),
      selected: this.weightDate > 0 ? new Date(this.weightDate) : new Date(),
      onDateAccept: (d: Date): void => { this.weightDate = d.getTime() }
    })
  }

  private maxWeight(): number {
    let m: number = 1
    for (let i = 0; i < this.weights.length; i++) if (this.weights[i].weightKg > m) m = this.weights[i].weightKg
    return m
  }
  private currentWeight(): number {
    return this.weights.length > 0 ? this.weights[this.weights.length - 1].weightKg : 0
  }

  private reversedWeights(): WeightEntry[] {
    const out: WeightEntry[] = []
    for (let i = this.weights.length - 1; i >= 0; i--) {
      out.push(this.weights[i])
    }
    return out
  }

  @Builder subTabs() {
    Row({ space: 3 }) {
      ForEach(['提醒', '记录', '档案'], (label: string, idx: number) => {
        Text(label)
          .fontSize(Theme.font.caption)
          .fontColor(this.subTab === idx ? Theme.color.textOnPrimary : Theme.color.textTertiary)
          .fontWeight(this.subTab === idx ? FontWeight.Medium : FontWeight.Normal)
          .layoutWeight(1).height(33).textAlign(TextAlign.Center)
          .borderRadius(Theme.radius.sm)
          .backgroundColor(this.subTab === idx ? Theme.color.primary : Color.Transparent)
          .onClick(() => { this.subTab = idx })
      })
    }
    .width('100%').padding(3).backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.sm)
    .border({ width: 1, color: Theme.color.borderSubtle })
  }

  @Builder remindersList() {
    Column({ space: 10 }) {
      ForEach(this.reminders, (r: HealthReminder) => {
        HealthReminderCard({
          reminder: r,
          actionLabel: r.type === 'vaccine' ? '找医院' : '已完成',
          onAction: (): void => {
            if (r.type === 'vaccine') { this.gotoHospital() } else { this.markDone(r) }
          },
          onDone: (): void => { this.markDone(r) }
        })
      })
      if (this.reminders.length === 0) {
        Text('暂无提醒，点右上角 + 添加').fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
          .width('100%').textAlign(TextAlign.Center).padding({ top: 40 })
      }
      this.weightCard()
    }.width('100%')
  }

  @Builder weightCard() {
    if (this.weights.length > 0) {
      Column({ space: 9 }) {
        Row() {
          Text('体重趋势').fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
          Blank()
          Text('当前 ' + this.currentWeight().toFixed(1) + ' kg').fontSize(Theme.font.footnote).fontColor(Theme.color.success)
        }.width('100%')
        Row({ space: 5 }) {
          ForEach(this.weights, (w: WeightEntry, i: number) => {
            Column()
              .layoutWeight(1)
              .height(Math.max(8, Math.round(44 * w.weightKg / this.maxWeight())))
              .borderRadius({ topLeft: 2, topRight: 2 })
              .backgroundColor(i === this.weights.length - 1 ? Theme.color.primary : Theme.color.primaryDim)
          })
        }.width('100%').height(44).alignItems(VerticalAlign.Bottom)
      }
      .width('100%').padding(13).backgroundColor(Theme.color.bgCard)
      .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
      .shadow(Theme.shadow.card)
    }
  }

  @Builder recordsList() {
    Column({ space: 10 }) {
      Row() {
        Text('体重记录').fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        Blank()
        Text('+ 记录体重').fontSize(Theme.font.footnote).fontColor(Theme.color.primary)
          .onClick(() => { this.showWeight = true })
      }.width('100%')

      if (this.weights.length === 0) {
        Text('暂无体重记录').fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
          .width('100%').textAlign(TextAlign.Center).padding({ top: 20, bottom: 20 })
      }
      ForEach(this.reversedWeights(), (w: WeightEntry) => {
        Row() {
          Text(Icons.weight).fontSize(16).fontColor(Theme.color.primary)
            .width(34).height(34).textAlign(TextAlign.Center).borderRadius(11)
            .backgroundColor(Theme.color.primaryDim)
          Column({ space: 2 }) {
            Text(w.weightKg.toFixed(1) + ' kg').fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
            Text(DateUtil.ymd(w.recordedAt)).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 10 })
        }
        .width('100%').padding(12).backgroundColor(Theme.color.bgCard)
        .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
        .shadow(Theme.shadow.card)
      })

      Text('就诊/疫苗记录').fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        .width('100%').margin({ top: 8 })
      if (this.records.length === 0) {
        Text('暂无就诊记录，去成长时间轴添加疫苗或体检里程碑。')
          .fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
          .width('100%').textAlign(TextAlign.Center).padding({ top: 18, bottom: 18 })
      }
      ForEach(this.records, (m: Milestone) => {
        Row() {
          Text(Catalog.milestoneGlyph(m.type)).fontSize(17)
            .width(34).height(34).textAlign(TextAlign.Center).borderRadius(11)
            .backgroundColor(Theme.color.bgCardElevated)
          Column({ space: 2 }) {
            Text(m.title).fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
            Text(DateUtil.ymd(m.date) + (m.note.length > 0 ? ' · ' + m.note : ''))
              .fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 10 })
        }
        .width('100%').padding(12).backgroundColor(Theme.color.bgCard)
        .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
        .shadow(Theme.shadow.card)
      })
    }.width('100%')
  }

  @Builder profileCard() {
    Column({ space: 12 }) {
      // 头部：渐变 banner
      Stack({ alignContent: Alignment.BottomStart }) {
        Column().width('100%').height('100%')
          .linearGradient({ angle: 135, colors: [['#FFF1DE', 0], ['#FFFFFF', 1]] })
        Column()
          .width(90).height(90).borderRadius(45)
          .backgroundColor(Theme.color.glowPrimarySm)
          .blur(28)
          .position({ x: '72%', y: -20 })
          .hitTestBehavior(HitTestMode.None)
        Column({ space: 3 }) {
          Text(this.pet.name.length > 0 ? this.pet.name + ' 的健康档案' : '健康档案')
            .fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
          Row({ space: 5 }) {
            Text(Icons.shieldCheck).fontSize(12).fontColor(Theme.color.success)
            Text('本地生成 · 可随记录自动更新')
              .fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
          }
        }.alignItems(HorizontalAlign.Start).padding(14)
      }
      .width('100%').height(80)
      .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })
      .clip(true)

      // 指标网格
      Row({ space: 8 }) {
        this.metricCard('当前体重', this.currentWeight() > 0 ? this.currentWeight().toFixed(1) + 'kg' : '--')
        this.metricCard('待处理提醒', this.pendingCount().toString())
        this.metricCard('体重记录', this.weights.length.toString())
      }.width('100%').padding({ left: 14, right: 14 })

      // 基本信息
      Column({ space: 0 }) {
        this.infoRow('宠物类型', this.pet.species === 'cat' ? '猫' : this.pet.species === 'dog' ? '犬' : '其他')
        Divider().color(Theme.color.borderSubtle)
        this.infoRow('品种', this.pet.breed.length > 0 ? this.pet.breed : '未填写')
        Divider().color(Theme.color.borderSubtle)
        this.infoRow('生日', this.pet.birthday > 0 ? DateUtil.ymd(this.pet.birthday) : '未填写')
        Divider().color(Theme.color.borderSubtle)
        this.infoRow('就诊/疫苗记录', this.records.length + ' 条')
        Divider().color(Theme.color.borderSubtle)
        this.infoRow('健康建议', this.pendingCount() > 0 ? '优先处理临近 / 逾期提醒' : '状态稳定，保持定期记录')
      }
      .width('100%').padding({ left: 14, right: 14, bottom: 14 })
      .backgroundColor(Theme.color.bgCard)
    }
    .width('100%')
    .backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
    .shadow(Theme.shadow.card)
    .clip(true)
  }

  @Builder metricCard(label: string, value: string) {
    Column({ space: 3 }) {
      Text(value).fontSize(Theme.font.subtitle).fontColor(Theme.color.primary).fontWeight(FontWeight.Medium)
      Text(label).fontSize(Theme.font.micro).fontColor(Theme.color.textTertiary)
    }
    .layoutWeight(1).padding({ top: 12, bottom: 12 })
    .backgroundColor(Theme.color.bgDeep).borderRadius(Theme.radius.sm)
    .border({ width: 1, color: Theme.color.borderSubtle })
  }

  @Builder infoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
      Blank()
      Text(value).fontSize(Theme.font.footnote).fontColor(Theme.color.textSecondary)
    }.width('100%')
  }

  private pendingCount(): number {
    let n: number = 0
    for (let i = 0; i < this.reminders.length; i++) {
      if (!this.reminders[i].done) n += 1
    }
    return n
  }

  @Builder addSheet() {
    Column({ space: 13 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('添加健康事项').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')

      Text('类型').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.healthTypes, (t: CategoryMeta) => {
          Row() {
            AppChip({ label: t.label, leadingGlyph: Catalog.healthGlyph(t.key),
              selected: this.addType === t.key, onTap: (): void => { this.addType = t.key } })
          }.margin({ right: 8, bottom: 8 })
        })
      }.width('100%')

      Row() {
        Text(Icons.calendar).fontSize(16).fontColor(Theme.color.textTertiary)
        Text(this.addDate > 0 ? DateUtil.ymd(this.addDate) : '选择到期日期（默认按周期推算）')
          .fontSize(Theme.font.caption).fontColor(this.addDate > 0 ? Theme.color.textPrimary : Theme.color.textTertiary)
          .margin({ left: 9 }).layoutWeight(1)
      }
      .width('100%').height(48).padding({ left: 14, right: 14 })
      .backgroundColor(Theme.color.bgInput).borderRadius(Theme.radius.input)
      .border({ width: 1, color: Theme.color.borderDefault })
      .onClick(() => this.pickDate())

      Text('提醒周期').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).width('100%')
      Row({ space: 7 }) {
        ForEach([1, 3, 6, 12], (m: number) => {
          AppChip({ label: m + '个月', selected: this.addCycle === m, onTap: (): void => { this.addCycle = m } })
        })
      }

      Row() {
        Text('到期提醒').fontSize(Theme.font.caption).fontColor(Theme.color.textSecondary)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.addNotify })
          .selectedColor(Theme.color.primary)
          .onChange((on: boolean) => { this.addNotify = on })
      }
      .width('100%').padding(11).backgroundColor(Theme.color.bgCard)
      .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })

      Text('保存').fontSize(Theme.font.body).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
        .width('100%').height(48).textAlign(TextAlign.Center)
        .backgroundColor(Theme.color.primary).borderRadius(Theme.radius.md)
        .onClick(() => this.saveHealth())
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  @Builder weightSheet() {
    Column({ space: 13 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('记录体重').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')

      TextInput({ placeholder: '体重 kg，如 12.5', text: this.weightText })
        .type(InputType.Number)
        .height(48).backgroundColor(Theme.color.bgInput).borderRadius(Theme.radius.input)
        .padding({ left: 14, right: 14 }).fontColor(Theme.color.textPrimary)
        .placeholderColor(Theme.color.textTertiary)
        .border({ width: 1, color: Theme.color.borderDefault })
        .onChange((v: string) => { this.weightText = v })

      Row() {
        Text(Icons.calendar).fontSize(16).fontColor(Theme.color.textTertiary)
        Text(this.weightDate > 0 ? DateUtil.ymd(this.weightDate) : '选择记录日期（默认今天）')
          .fontSize(Theme.font.caption).fontColor(this.weightDate > 0 ? Theme.color.textPrimary : Theme.color.textTertiary)
          .margin({ left: 9 }).layoutWeight(1)
      }
      .width('100%').height(48).padding({ left: 14, right: 14 })
      .backgroundColor(Theme.color.bgInput).borderRadius(Theme.radius.input)
      .border({ width: 1, color: Theme.color.borderDefault })
      .onClick(() => this.pickWeightDate())

      Text('保存体重').fontSize(Theme.font.body).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
        .width('100%').height(48).textAlign(TextAlign.Center)
        .backgroundColor(Theme.color.primary).borderRadius(Theme.radius.md)
        .onClick(() => this.saveWeight())
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('健康管理').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        Blank()
        Text(Icons.plus).fontSize(19).fontColor(Theme.color.primary)
          .width(34).height(34).textAlign(TextAlign.Center).borderRadius(17)
          .backgroundColor(Theme.color.primaryDim).border({ width: 1, color: Theme.color.borderActive })
          .onClick(() => { this.subTab === 1 ? this.showWeight = true : this.showAdd = true })
      }.width('100%').height(40).alignItems(VerticalAlign.Center)

      this.subTabs()

      Scroll() {
        Column() {
          if (this.subTab === 0) {
            this.remindersList()
          } else if (this.subTab === 1) {
            this.recordsList()
          } else {
            this.profileCard()
          }
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
    .bindSheet($$this.showWeight, this.weightSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showWeight = false }
    })
  }
}
