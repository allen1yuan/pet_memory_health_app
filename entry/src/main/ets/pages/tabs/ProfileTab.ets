// ============================================================
// 宠忆时光 - 我的 Tab
// entry/src/main/ets/pages/tabs/ProfileTab.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { PetAvatar } from '../../components'
import { Theme } from '../../common/Theme'
import { Icons } from '../../common/Icons'
import { AppConstants } from '../../common/Constants'
import { DateUtil } from '../../common/DateUtil'
import { PrefStore } from '../../service/PrefStore'
import { PetStore } from '../../service/PetStore'
import { Pet } from '../../model/PetModels'

class PetSetupRouteParams {
  editId: number = 0
}

@Component
export struct ProfileTab {
  @Prop @Watch('onTick') tick: number = 0
  @State pets: Pet[] = []
  @State phone: string = ''
  @State planName: string = '免费版'
  @State notifyEnabled: boolean = true
  @State userName: string = '宠忆用户'
  @State draftUserName: string = ''
  @State showEditProfile: boolean = false
  @State showPrivacy: boolean = false
  @State showAbout: boolean = false

  async aboutToAppear(): Promise<void> { await this.reload() }
  onTick(): void { this.reload() }

  private async reload(): Promise<void> {
    this.pets = await PetStore.listPets()
    this.phone = PrefStore.getString(AppConstants.KEY_PHONE, 'demo_user')
    this.planName = PrefStore.getString(AppConstants.KEY_PLAN_NAME, '免费版')
    this.notifyEnabled = PrefStore.getBool(AppConstants.KEY_NOTIFY_ENABLED, true)
    this.userName = PrefStore.getString(AppConstants.KEY_USER_NAME, '宠忆用户')
  }

  private toast(msg: string): void { promptAction.showToast({ message: msg, duration: 1500 }) }

  private companionDays(): number {
    if (this.pets.length === 0) return 0
    let min: number = Date.now()
    for (let i = 0; i < this.pets.length; i++) {
      if (this.pets[i].createdAt > 0 && this.pets[i].createdAt < min) min = this.pets[i].createdAt
    }
    return DateUtil.daysSince(min) + 1
  }

  private ageText(pet: Pet): string {
    const parts: string[] = []
    if (pet.breed.length > 0) parts.push(pet.breed)
    if (pet.birthday > 0) {
      const years: number = Math.max(0, Math.floor(DateUtil.daysSince(pet.birthday) / 365))
      parts.push(years + '岁')
    }
    parts.push(pet.gender === 'female' ? '母' : '公')
    return parts.join(' · ')
  }

  private editPet(id: number): void {
    const params = new PetSetupRouteParams()
    params.editId = id
    this.getUIContext().getRouter().pushUrl({
      url: AppConstants.PAGE_PET_SETUP, params: params
    })
  }

  private addPet(): void {
    this.getUIContext().getRouter().pushUrl({ url: AppConstants.PAGE_PET_SETUP })
  }

  private gotoPlans(): void {
    this.getUIContext().getRouter().pushUrl({ url: AppConstants.PAGE_PLANS })
  }

  private logout(): void {
    PrefStore.endSession()
    this.toast('已退出登录')
    this.getUIContext().getRouter().replaceUrl({ url: AppConstants.PAGE_LOGIN })
  }

  private toggleNotify(on: boolean): void {
    this.notifyEnabled = on
    PrefStore.setBool(AppConstants.KEY_NOTIFY_ENABLED, on)
    this.toast(on ? '已开启本地提醒' : '已关闭本地提醒')
  }

  private openEditProfile(): void {
    this.draftUserName = this.userName
    this.showEditProfile = true
  }

  private saveProfile(): void {
    const next: string = this.draftUserName.trim().length > 0 ? this.draftUserName.trim() : '宠忆用户'
    this.userName = next
    PrefStore.setString(AppConstants.KEY_USER_NAME, next)
    this.showEditProfile = false
    this.toast('资料已保存到本机')
  }

  @Builder petRow(pet: Pet) {
    Row({ space: 11 }) {
      PetAvatar({ name: pet.name, species: pet.species, avatarUri: pet.avatarUri, active: false, avatarSize: 44, showLabel: false })
      Column({ space: 1 }) {
        Text(pet.name).fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        Text(this.ageText(pet)).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text(Icons.chevronRight).fontSize(16).fontColor(Theme.color.textDisabled)
    }
    .width('100%').padding(11).backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
    .shadow(Theme.shadow.card)
    .onClick(() => this.editPet(pet.id))
  }

  @Builder settingRow(glyph: string, label: string, danger: boolean, onTap: () => void) {
    Row({ space: 11 }) {
      Text(glyph).fontSize(16).fontColor(danger ? Theme.color.error : Theme.color.textTertiary)
        .width(34).height(34).textAlign(TextAlign.Center).borderRadius(11)
        .backgroundColor(danger ? '#FCEAE7' : Theme.color.bgCardElevated)
      Text(label).fontSize(Theme.font.caption).fontColor(danger ? Theme.color.error : Theme.color.textSecondary).layoutWeight(1)
      if (!danger) Text(Icons.chevronRight).fontSize(15).fontColor(Theme.color.textDisabled)
    }
    .width('100%').padding(13).backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
    .shadow(Theme.shadow.card)
    .onClick(onTap)
  }

  @Builder notifyRow() {
    Row({ space: 11 }) {
      Text(Icons.bell).fontSize(16).fontColor(Theme.color.textTertiary)
        .width(34).height(34).textAlign(TextAlign.Center).borderRadius(11)
        .backgroundColor(Theme.color.bgCardElevated)
      Column({ space: 2 }) {
        Text('通知设置').fontSize(Theme.font.caption).fontColor(Theme.color.textSecondary)
        Text(this.notifyEnabled ? '本地提醒已开启' : '本地提醒已关闭')
          .fontSize(Theme.font.micro).fontColor(Theme.color.textTertiary)
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: this.notifyEnabled })
        .selectedColor(Theme.color.primary)
        .onChange((on: boolean) => this.toggleNotify(on))
    }
    .width('100%').padding(13).backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
    .shadow(Theme.shadow.card)
  }

  @Builder editProfileSheet() {
    Column({ space: 13 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('编辑资料').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
      TextInput({ placeholder: '昵称', text: this.draftUserName })
        .height(48).backgroundColor(Theme.color.bgInput).borderRadius(Theme.radius.input)
        .padding({ left: 14, right: 14 }).fontColor(Theme.color.textPrimary)
        .placeholderColor(Theme.color.textTertiary)
        .border({ width: 1, color: Theme.color.borderDefault })
        .onChange((v: string) => { this.draftUserName = v })
      Text('登录账号：' + this.phone).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).width('100%')
      Text('保存资料').fontSize(Theme.font.body).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
        .width('100%').height(48).textAlign(TextAlign.Center)
        .backgroundColor(Theme.color.primary).borderRadius(Theme.radius.md)
        .onClick(() => this.saveProfile())
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  @Builder privacySheet() {
    Column({ space: 12 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('隐私与安全').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
      this.privacyRow(Icons.lock, '本地存储', '宠物、相册记录、健康数据都保存在本机数据库。')
      this.privacyRow(Icons.bell, '本地提醒', this.notifyEnabled ? '已开启提醒开关。' : '提醒开关已关闭。')
      this.privacyRow(Icons.shieldCheck, '演示数据', '医院、会员、账号均为 fake data，不连接真实后端。')
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  @Builder privacyRow(glyph: string, title: string, desc: string) {
    Row({ space: 10 }) {
      Text(glyph).fontSize(18).fontColor(Theme.color.primary)
      Column({ space: 2 }) {
        Text(title).fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        Text(desc).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
    }
    .width('100%').padding(12).backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
    .shadow(Theme.shadow.card)
  }

  @Builder aboutSheet() {
    Column({ space: 12 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('关于宠医星').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
      Text('宠医星是本地模拟的第三方中立认证模块，用于演示医院筛选、详情查看与预约流程。')
        .fontSize(Theme.font.caption).fontColor(Theme.color.textSecondary).lineHeight(20).width('100%')
      this.privacyRow(Icons.star, '星级说明', '三星、二星、一星来自 fake rawfile 数据。')
      this.privacyRow(Icons.hospital, '预约流程', '提交后只记录当前页面状态，不会发送真实预约。')
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('我的').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
          .width('100%').height(40)

        // 用户卡
        Row({ space: 13 }) {
          Text(Icons.mine).fontSize(26).fontColor(Theme.color.primary)
            .width(56).height(56).textAlign(TextAlign.Center).borderRadius(28)
            .backgroundColor(Theme.color.primaryDim).border({ width: 2, color: Theme.color.borderActive })
          Column({ space: 3 }) {
            Text(this.userName).fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
            Text(this.phone + ' · 陪伴第 ' + this.companionDays() + ' 天').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          Text(Icons.edit).fontSize(18).fontColor(Theme.color.textTertiary).onClick(() => this.openEditProfile())
        }
        .width('100%').padding(15).backgroundColor(Theme.color.bgCard)
        .borderRadius(Theme.radius.md).border({ width: 1, color: Theme.color.borderDefault })
        .shadow(Theme.shadow.card)

        // 会员入口
        Row() {
          Row({ space: 10 }) {
            Text(Icons.crown).fontSize(20).fontColor(Theme.color.primary)
              .width(40).height(40).textAlign(TextAlign.Center).borderRadius(20)
              .backgroundColor(Theme.color.primaryDim)
            Column({ space: 1 }) {
              Text(this.planName).fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
              Text('查看或切换本地会员方案').fontSize(Theme.font.footnote).fontColor(Theme.color.primary)
            }.alignItems(HorizontalAlign.Start)
          }
          Blank()
          Text('查看').fontSize(Theme.font.footnote).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .backgroundColor(Theme.color.primary).borderRadius(Theme.radius.sm)
        }
        .width('100%').padding(13)
        .linearGradient({ angle: 135, colors: [['#FFF1DE', 0], ['#FFFFFF', 1]] })
        .borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.color.borderActive })
        .shadow(Theme.shadow.card)
        .onClick(() => this.gotoPlans())

        Text('我的宠物').fontSize(Theme.font.caption).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
        ForEach(this.pets, (p: Pet) => { this.petRow(p) })
        Row({ space: 7 }) {
          Text(Icons.plus).fontSize(16).fontColor(Theme.color.textTertiary)
          Text('添加宠物').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
        }
        .width('100%').height(46).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.color.borderDefault, style: BorderStyle.Dashed })
        .onClick(() => this.addPet())

        this.notifyRow()
        this.settingRow(Icons.lock, '隐私与安全', false, () => { this.showPrivacy = true })
        this.settingRow(Icons.help, '关于宠医星', false, () => { this.showAbout = true })
        this.settingRow(Icons.logout, '退出登录', true, () => this.logout())
        Column().height(12)
      }
      .width('100%').padding({ left: 16, right: 16 })
    }
    .width('100%').height('100%')
    .scrollBar(BarState.Off).align(Alignment.Top)
    .padding({ top: 36 })
    .backgroundColor(Theme.color.bgBase)
    .bindSheet($$this.showEditProfile, this.editProfileSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showEditProfile = false }
    })
    .bindSheet($$this.showPrivacy, this.privacySheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showPrivacy = false }
    })
    .bindSheet($$this.showAbout, this.aboutSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showAbout = false }
    })
  }
}
