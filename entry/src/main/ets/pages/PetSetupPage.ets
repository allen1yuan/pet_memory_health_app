// ============================================================
// 宠忆时光 - 建立/编辑宠物档案
// entry/src/main/ets/pages/PetSetupPage.ets
//
// 无参数 = 新建（建档后写入示例数据并进入 MainPage）
// 参数 editId = 编辑既有宠物
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppButton, AppButtonType, AppInput, AppInputType } from '../components'
import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { AppConstants } from '../common/Constants'
import { DateUtil } from '../common/DateUtil'
import { AppInit } from '../service/AppInit'
import { PrefStore } from '../service/PrefStore'
import { PetStore } from '../service/PetStore'
import { SeedData } from '../service/SeedData'
import { PhotoPickerUtil } from '../service/PhotoPickerUtil'
import { Pet } from '../model/PetModels'

const TAG: string = 'ChongYiPetSetup'
const DOMAIN: number = 0xFF00

class PetSetupRouteParams {
  editId: number = 0
}

@Entry
@Component
struct PetSetupPage {
  @State name: string = ''
  @State species: string = 'dog'
  @State breed: string = ''
  @State birthday: number = 0
  @State gender: string = 'male'
  @State weightText: string = ''
  @State avatarUri: string = ''
  @State saving: boolean = false
  @State editId: number = 0
  @State canGoBack: boolean = false
  @State private avatarPulse: number = 0
  private ctx: common.UIAbilityContext | null = null

  async aboutToAppear(): Promise<void> {
    this.ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    await AppInit.ensure(this.ctx)
    animateTo({ duration: 2600, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate }, () => {
      this.avatarPulse = 1
    })
    // 路由栈深度 > 1 说明是从其他页面 push 进来的（如「我的」加宠物），应显示返回；
    // 首次 onboarding 用 replaceUrl 进入，栈深度恒为 1，不显示返回
    this.canGoBack = Number(this.getUIContext().getRouter().getLength()) > 1
    const params = this.getUIContext().getRouter().getParams() as PetSetupRouteParams
    if (params && params.editId > 0) {
      this.editId = params.editId
      const pet = await PetStore.getPet(this.editId)
      if (pet) {
        this.name = pet.name; this.species = pet.species; this.breed = pet.breed
        this.birthday = pet.birthday; this.gender = pet.gender
        this.weightText = pet.weightKg > 0 ? pet.weightKg.toString() : ''
        this.avatarUri = pet.avatarUri
      }
    }
  }

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: 1600 })
  }

  private isEdit(): boolean { return this.editId > 0 }

  private async pickAvatar(): Promise<void> {
    if (!this.ctx) return
    const uris: string[] = await PhotoPickerUtil.pickAndStore(this.ctx, 1)
    if (uris.length > 0) this.avatarUri = uris[0]
  }

  private pickBirthday(): void {
    this.getUIContext().showDatePickerDialog({
      start: new Date('2005-1-1'),
      end: new Date(),
      selected: this.birthday > 0 ? new Date(this.birthday) : new Date(),
      onDateAccept: (d: Date) => { this.birthday = d.getTime() }
    })
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) { this.toast('请填写宠物昵称'); return }
    this.saving = true
    const pet = new Pet()
    pet.id = this.editId
    pet.name = this.name.trim()
    pet.species = this.species
    pet.breed = this.breed.trim()
    pet.birthday = this.birthday
    pet.gender = this.gender
    const parsedWeight: number = this.weightText.length > 0 ? parseFloat(this.weightText) : 0
    pet.weightKg = Number.isNaN(parsedWeight) ? 0 : parsedWeight
    pet.avatarUri = this.avatarUri
    try {
      if (this.isEdit()) {
        await PetStore.updatePet(pet)
        this.saving = false
        this.toast('档案已更新')
        this.getUIContext().getRouter().back()
      } else {
        const petId: number = await PetStore.insertPet(pet)
        PrefStore.setCurrentPetId(petId)
        PrefStore.markOnboarded()
        await SeedData.seedForPet(petId, pet.name, pet.birthday)
        this.saving = false
        this.toast('档案已创建')
        if (this.canGoBack) {
          // 从「我的」加宠物进来：返回已有的 MainPage，而不是再叠一个新实例
          this.getUIContext().getRouter().back()
        } else {
          // 首次 onboarding：此时栈里还没有 MainPage，只能新建
          this.getUIContext().getRouter().replaceUrl({ url: AppConstants.PAGE_MAIN })
        }
      }
    } catch (e) {
      this.saving = false
      const detail: string = e instanceof Error ? e.message : JSON.stringify(e)
      hilog.error(DOMAIN, TAG, 'save pet failed: ' + detail)
      promptAction.showToast({ message: '保存失败：' + detail, duration: 3500 })
    }
  }

  @Builder speciesChip(key: string, glyph: string, label: string) {
    Column({ space: 3 }) {
      Text(glyph).fontSize(17).fontColor(this.species === key ? Theme.color.primary : Theme.color.textTertiary)
      Text(label).fontSize(Theme.font.micro).fontColor(this.species === key ? Theme.color.primary : Theme.color.textTertiary)
    }
    .layoutWeight(1).height(50).justifyContent(FlexAlign.Center)
    .backgroundColor(this.species === key ? Theme.color.primaryDim : Theme.color.bgCard)
    .borderRadius(Theme.radius.sm)
    .border({ width: this.species === key ? 1.5 : 1, color: this.species === key ? Theme.color.primary : Theme.color.borderDefault })
    .shadow(this.species === key ? Theme.shadow.card : undefined)
    .onClick(() => { this.species = key })
  }

  @Builder genderChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.font.caption)
      .fontColor(this.gender === key ? Theme.color.primary : Theme.color.textTertiary)
      .layoutWeight(1).height(46).textAlign(TextAlign.Center)
      .backgroundColor(this.gender === key ? Theme.color.primaryDim : Theme.color.bgCard)
      .borderRadius(Theme.radius.sm)
      .border({ width: 1, color: this.gender === key ? Theme.color.borderActive : Theme.color.borderDefault })
      .onClick(() => { this.gender = key })
  }

  @Builder fieldLabel(text: string) {
    Text(text).fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
      .width('100%').margin({ bottom: 7 })
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        if (this.isEdit() || this.canGoBack) {
          Text(Icons.back).fontSize(24).fontColor(Theme.color.textTertiary)
            .onClick(() => this.getUIContext().getRouter().back())
        }
        Text(this.isEdit() ? '编辑档案' : '建立宠物档案')
          .fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary)
          .fontWeight(FontWeight.Medium).margin({ left: (this.isEdit() || this.canGoBack) ? 6 : 0 })
      }
      .width('100%').height(44).alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          Text('先认识一下你的毛孩子，方便为它记录成长与健康。')
            .fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary)
            .width('100%')

          // 头像（柔光呼吸光环 + 头像本体）
          Column({ space: 4 }) {
            Stack() {
              Column()
                .width(116).height(116).borderRadius(58)
                .radialGradient({ center: ['50%', '50%'], radius: '50%', colors: [['#38FFD9A6', 0], ['#00FFD9A6', 1]] })
                .scale({ x: 1 + this.avatarPulse * 0.1, y: 1 + this.avatarPulse * 0.1 })
                .opacity(0.65 + this.avatarPulse * 0.35)
                .hitTestBehavior(HitTestMode.None)
              Stack() {
                if (this.avatarUri.length > 0) {
                  Image(this.avatarUri).width(88).height(88).borderRadius(44).objectFit(ImageFit.Cover)
                } else {
                  Column({ space: 3 }) {
                    Text(Icons.camera).fontSize(26).fontColor(Theme.color.textTertiary)
                    Text('上传头像').fontSize(Theme.font.micro).fontColor(Theme.color.textDisabled)
                  }
                }
              }
              .width(88).height(88).borderRadius(44)
              .backgroundColor(Theme.color.bgCard)
              .border({ width: 2, color: this.avatarUri.length > 0 ? Theme.color.primary : Theme.color.borderDefault })
              .shadow(Theme.shadow.card)
              .alignContent(Alignment.Center)
              .onClick(() => this.pickAvatar())
            }
            .width(116).height(116).alignContent(Alignment.Center)
          }
          .width('100%')

          Column() {
            this.fieldLabel('宠物昵称')
            AppInput({ placeholder: '给毛孩子起个名字', value: $name })
          }.width('100%')

          Column() {
            this.fieldLabel('类型')
            Row({ space: 8 }) {
              this.speciesChip('dog', Icons.dog, '犬')
              this.speciesChip('cat', Icons.cat, '猫')
              this.speciesChip('other', Icons.paw, '其他')
            }.width('100%')
          }.width('100%')

          Column() {
            this.fieldLabel('品种')
            AppInput({ placeholder: '如：柴犬 / 英短', value: $breed })
          }.width('100%')

          Row({ space: 10 }) {
            Column() {
              this.fieldLabel('生日')
              Row() {
                Text(Icons.calendar).fontSize(16).fontColor(Theme.color.textTertiary)
                Text(this.birthday > 0 ? DateUtil.ymd(this.birthday) : '选择日期')
                  .fontSize(Theme.font.caption)
                  .fontColor(this.birthday > 0 ? Theme.color.textPrimary : Theme.color.textTertiary)
                  .margin({ left: 9 }).layoutWeight(1)
              }
              .width('100%').height(50).padding({ left: 14, right: 14 })
              .backgroundColor(Theme.color.bgInput).borderRadius(Theme.radius.input)
              .border({ width: 1, color: Theme.color.borderDefault })
              .onClick(() => this.pickBirthday())
            }.layoutWeight(1)

            Column() {
              this.fieldLabel('性别')
              Row({ space: 8 }) {
                this.genderChip('male', '公')
                this.genderChip('female', '母')
              }.width('100%')
            }.layoutWeight(1)
          }.width('100%').alignItems(VerticalAlign.Top)

          Column() {
            this.fieldLabel('体重 (kg)')
            AppInput({ placeholder: '如：12.3', value: $weightText })
          }.width('100%')

          AppButton({
            label: this.isEdit() ? '保存' : '完成，开始记录',
            type: AppButtonType.Primary,
            loading: this.saving,
            onTap: () => this.save()
          }).margin({ top: 6 })

          Text('资料可随时在「我的」中修改')
            .fontSize(Theme.font.micro).fontColor(Theme.color.textDisabled)
            .width('100%').textAlign(TextAlign.Center).margin({ bottom: 20 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.color.bgBase)
    .padding({ left: 16, right: 16, top: 36 })
  }
}
