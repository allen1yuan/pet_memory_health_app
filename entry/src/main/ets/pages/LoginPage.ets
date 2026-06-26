// ============================================================
// 宠忆时光 - 登录页（本地门禁，无服务端短信）
// entry/src/main/ets/pages/LoginPage.ets
//
// MVP：手机号 11 位 + 任意 6 位验证码即可进入；启动本地会话。
// 登录后：已有宠物 → MainPage，否则 → PetSetupPage。
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppButton, AppButtonType, AppInput, AppInputType, BrandLogo } from '../components'
import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { AppConstants } from '../common/Constants'
import { AppInit } from '../service/AppInit'
import { PrefStore } from '../service/PrefStore'
import { PetStore } from '../service/PetStore'
import { SeedData } from '../service/SeedData'

const TAG: string = 'ChongYiLogin'
const DOMAIN: number = 0xFF00

@Entry
@Component
struct LoginPage {
  @State phone: string = ''
  @State code: string = ''
  @State phoneError: string = ''
  @State codeError: string = ''
  @State countdown: number = 0
  @State loading: boolean = false
  private timerId: number = -1
  private ctx: common.UIAbilityContext | null = null

  async aboutToAppear(): Promise<void> {
    this.ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    await AppInit.ensure(this.ctx)
  }

  // 兜底：防止用户在首次冷启动、数据库尚未建表完成时就点了登录/演示按钮
  private async ensureReady(): Promise<void> {
    if (this.ctx) await AppInit.ensure(this.ctx)
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) clearInterval(this.timerId)
  }

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: 1600 })
  }

  private validPhone(): boolean {
    return /^1\d{10}$/.test(this.phone)
  }

  private sendCode(): void {
    if (!this.validPhone()) {
      this.phoneError = '请输入正确的手机号'
      return
    }
    this.phoneError = ''
    this.countdown = 60
    this.toast('验证码已发送（演示：任意 6 位即可）')
    this.timerId = setInterval(() => {
      this.countdown -= 1
      if (this.countdown <= 0) {
        clearInterval(this.timerId)
        this.timerId = -1
      }
    }, 1000)
  }

  private async doLogin(): Promise<void> {
    if (!this.validPhone()) { this.phoneError = '请输入正确的手机号'; return }
    if (this.code.length !== 6) { this.codeError = '请输入 6 位验证码'; return }
    this.phoneError = ''
    this.codeError = ''
    this.loading = true
    try {
      await this.ensureReady()
      PrefStore.startSession(this.phone)
      const count: number = await PetStore.countPets()
      this.loading = false
      if (count > 0) {
        PrefStore.markOnboarded()
        this.getUIContext().getRouter().replaceUrl({ url: AppConstants.PAGE_MAIN })
      } else {
        this.getUIContext().getRouter().replaceUrl({ url: AppConstants.PAGE_PET_SETUP })
      }
    } catch (e) {
      this.loading = false
      const detail: string = e instanceof Error ? e.message : JSON.stringify(e)
      hilog.error(DOMAIN, TAG, 'doLogin failed: ' + detail)
      promptAction.showToast({ message: '登录失败：' + detail, duration: 3500 })
    }
  }

  private huaweiLogin(): void {
    // MVP：本地化处理（无真实 client_id 时直接进入本地会话）
    PrefStore.startSession('huawei_user')
    this.demoLogin()
  }

  private async demoLogin(): Promise<void> {
    this.loading = true
    try {
      await this.ensureReady()
      PrefStore.startSession(this.phone.length > 0 ? this.phone : 'demo_user')
      const petId: number = await SeedData.seedDemoIfEmpty()
      if (petId > 0) PrefStore.setCurrentPetId(petId)
      PrefStore.markOnboarded()
      this.loading = false
      this.toast('已进入本地演示数据')
      this.getUIContext().getRouter().replaceUrl({ url: AppConstants.PAGE_MAIN })
    } catch (e) {
      this.loading = false
      const detail: string = e instanceof Error ? e.message : JSON.stringify(e)
      hilog.error(DOMAIN, TAG, 'demoLogin failed: ' + detail)
      promptAction.showToast({ message: '演示数据初始化失败：' + detail, duration: 3500 })
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%').height('100%')
        .backgroundColor(Theme.color.bgBase)

      // 环境光晕
      Column()
        .width(280).height(280).borderRadius(140)
        .backgroundColor(Theme.color.glowPrimaryMd)
        .blur(60)
        .position({ x: -60, y: -80 })
      Column()
        .width(220).height(220).borderRadius(110)
        .backgroundColor(Theme.color.glowAccentSm)
        .blur(60)
        .position({ x: '70%', y: '70%' })

      Column({ space: 14 }) {
        BrandLogo({ logoSize: 56, withGlow: true })
          .margin({ bottom: 4 })
        Text('宠忆时光')
          .fontSize(Theme.font.h2)
          .fontColor(Theme.color.textPrimary)
          .fontWeight(FontWeight.Medium)
          .letterSpacing(4)
        Text('一次授权，全程自动')
          .fontSize(Theme.font.footnote)
          .fontColor(Theme.color.textTertiary)
          .margin({ bottom: 8 })

        Column({ space: 14 }) {
          AppInput({
            placeholder: '请输入手机号码',
            inputType: AppInputType.PhoneNumber,
            value: $phone,
            errorMsg: this.phoneError
          })

          AppInput({
            placeholder: '短信验证码',
            inputType: AppInputType.Text,
            value: $code,
            trailingAction: '获取验证码',
            countdown: this.countdown,
            errorMsg: this.codeError,
            onTrailingTap: () => this.sendCode()
          })

          AppButton({
            label: '登录 / 注册',
            type: AppButtonType.Primary,
            loading: this.loading,
            onTap: () => this.doLogin()
          })
            .margin({ top: 4 })
        }
        .width('100%').padding(16)
        .backgroundColor(Theme.color.bgCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.color.borderSubtle })
        .shadow(Theme.shadow.card)

        Row({ space: 10 }) {
          Divider().layoutWeight(1).color(Theme.color.divider)
          Text('或使用').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
          Divider().layoutWeight(1).color(Theme.color.divider)
        }.width('100%').margin({ top: 4, bottom: 4 })

        AppButton({
          label: 'Huawei ID 一键登录',
          type: AppButtonType.Secondary,
          leadingIcon: null,
          onTap: () => this.huaweiLogin()
        })

        AppButton({
          label: '使用本地演示数据',
          type: AppButtonType.Secondary,
          onTap: () => this.demoLogin()
        })

        Row() {
          Text('登录即同意 ').fontSize(Theme.font.micro).fontColor(Theme.color.textTertiary)
          Text('用户协议').fontSize(Theme.font.micro).fontColor(Theme.color.primary)
          Text(' 与 ').fontSize(Theme.font.micro).fontColor(Theme.color.textTertiary)
          Text('隐私政策').fontSize(Theme.font.micro).fontColor(Theme.color.primary)
        }.margin({ top: 6 })
      }
      .width('100%')
      .padding({ left: 28, right: 28 })
      .justifyContent(FlexAlign.Center)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
