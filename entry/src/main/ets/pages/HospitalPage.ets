// ============================================================
// 宠忆时光 - 宠医星认证医院列表（静态数据 + 星级筛选）
// entry/src/main/ets/pages/HospitalPage.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { AppChip, HospitalCard } from '../components'
import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { AppConstants } from '../common/Constants'
import { HospitalRepo } from '../service/HospitalRepo'
import { Hospital } from '../model/PetModels'

class HospitalDetailRouteParams {
  hospitalId: string = ''
}

@Entry
@Component
struct HospitalPage {
  @State all: Hospital[] = []
  @State shown: Hospital[] = []
  @State starFilter: number = 0
  @State keyword: string = ''
  @State city: string = '北京'
  @State bookedHospitalId: string = ''

  async aboutToAppear(): Promise<void> {
    const ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    this.all = await HospitalRepo.load(ctx)
    this.applyFilter()
  }

  private applyFilter(): void {
    const list: Hospital[] = []
    const kw: string = this.keyword.trim()
    for (let i = 0; i < this.all.length; i++) {
      const h: Hospital = this.all[i]
      const matchStar: boolean = this.starFilter <= 0 || h.star === this.starFilter
      const matchKw: boolean = kw.length === 0 || h.name.indexOf(kw) >= 0 || h.address.indexOf(kw) >= 0 || h.services.join(',').indexOf(kw) >= 0
      if (matchStar && matchKw) list.push(h)
    }
    this.shown = list
  }

  private setFilter(star: number): void {
    this.starFilter = star
    this.applyFilter()
  }

  private toast(msg: string): void { promptAction.showToast({ message: msg, duration: 1500 }) }

  private switchCity(): void {
    this.city = this.city === '北京' ? '上海' : '北京'
    this.toast('已切换到' + this.city + '（演示数据仍为本地模拟）')
  }

  private book(h: Hospital): void {
    this.bookedHospitalId = h.id
    this.toast('已为 ' + h.name + ' 提交本地预约')
  }

  private openDetail(h: Hospital): void {
    const params = new HospitalDetailRouteParams()
    params.hospitalId = h.id
    this.getUIContext().getRouter().pushUrl({
      url: AppConstants.PAGE_HOSPITAL_DETAIL, params: params
    })
  }

  @Builder starChip(star: number, label: string) {
    AppChip({
      label: label,
      leadingGlyph: star > 0 ? Icons.star : '',
      selected: this.starFilter === star,
      onTap: (): void => this.setFilter(star)
    })
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Row({ space: 7 }) {
          Text(Icons.back).fontSize(24).fontColor(Theme.color.textTertiary)
            .onClick(() => this.getUIContext().getRouter().back())
          Text('宠医星').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        }
        Blank()
        Row({ space: 5 }) {
          Text(Icons.mapPin).fontSize(13).fontColor(Theme.color.textTertiary)
          Text(this.city).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
          Text(Icons.chevronDown).fontSize(11).fontColor(Theme.color.textDisabled)
        }
        .padding({ left: 11, right: 11, top: 5, bottom: 5 })
        .backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.pill)
        .border({ width: 1, color: Theme.color.borderDefault })
        .onClick(() => this.switchCity())
      }.width('100%').height(40).alignItems(VerticalAlign.Center)

      Row({ space: 9 }) {
        Text(Icons.search).fontSize(16).fontColor(Theme.color.textDisabled)
        TextInput({ placeholder: '搜索医院名称、地址或服务', text: this.keyword })
          .fontSize(Theme.font.caption)
          .fontColor(Theme.color.textPrimary)
          .placeholderColor(Theme.color.textDisabled)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .padding(0)
          .onChange((v: string) => { this.keyword = v; this.applyFilter() })
      }
      .width('100%').height(42).padding({ left: 13, right: 13 })
      .backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.sm)
      .border({ width: 1, color: Theme.color.borderDefault })

      // 中立认证说明
      Row({ space: 8 }) {
        Text(Icons.shieldCheck).fontSize(15).fontColor(Theme.color.success)
        Text('宠医星为第三方中立认证，不接受医院赞助')
          .fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).layoutWeight(1)
      }
      .width('100%').padding({ left: 12, right: 12, top: 9, bottom: 9 })
      .backgroundColor('#27200F').borderRadius(Theme.radius.sm)
      .border({ width: 1, color: '#5A431F' })

      Row({ space: 7 }) {
        this.starChip(0, '全部')
        this.starChip(3, '三星')
        this.starChip(2, '二星')
        this.starChip(1, '一星')
      }.width('100%')

      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.shown, (h: Hospital) => {
            HospitalCard({
              hospital: h,
              onOpen: (): void => this.openDetail(h),
              onBook: (): void => this.book(h)
            })
            if (this.bookedHospitalId === h.id) {
              Text('已提交预约 · 医院将电话确认')
                .fontSize(Theme.font.footnote).fontColor(Theme.color.success)
                .width('100%').padding({ left: 12, right: 12, bottom: 6 })
            }
          })
          if (this.shown.length === 0) {
            Text('该星级暂无医院').fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
              .width('100%').textAlign(TextAlign.Center).padding({ top: 40 })
          }
          Column().height(12)
        }.width('100%')
      }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
    }
    .width('100%').height('100%')
    .padding({ left: 16, right: 16, top: 36 })
    .backgroundColor(Theme.color.bgBase)
  }
}
