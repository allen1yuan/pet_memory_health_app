// ============================================================
// PhotoTile —— 相册九宫格单元（图片 + 可选分类角标）
// ============================================================

import { Theme } from '../common/Theme'

const DEMO_PREFIX: string = 'demo://'

function demoCategory(uri: string): string {
  return uri.startsWith(DEMO_PREFIX) ? uri.substring(DEMO_PREFIX.length) : ''
}

function demoBg(cat: string): string {
  if (cat === 'outdoor') return '#EDF8F2'
  if (cat === 'hospital') return '#EDF2FF'
  if (cat === 'food') return '#FFFBEA'
  if (cat === 'other') return '#F5F0FF'
  return '#FFF8F2'
}

function demoEmoji(cat: string): string {
  if (cat === 'outdoor') return '🌿'
  if (cat === 'hospital') return '🏥'
  if (cat === 'food') return '🍖'
  if (cat === 'other') return '🎀'
  return '🐾'
}

function demoCatLabel(cat: string): string {
  if (cat === 'outdoor') return '户外'
  if (cat === 'hospital') return '医院'
  if (cat === 'food') return '美食'
  if (cat === 'other') return '其他'
  return '日常'
}

@Component
export struct PhotoTile {
  @Prop uri: string = ''
  @Prop badge: string = ''
  onTap?: () => void

  private isDemo(): boolean {
    return this.uri.startsWith(DEMO_PREFIX)
  }

  private cat(): string {
    return demoCategory(this.uri)
  }

  @Builder demoTile() {
    Column({ space: 5 }) {
      Text(demoEmoji(this.cat())).fontSize(26)
      Text(demoCatLabel(this.cat()))
        .fontSize(Theme.font.micro)
        .fontColor('#888888')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(demoBg(this.cat()))
    .borderRadius(Theme.radius.sm)
  }

  @Builder realImage() {
    Image(this.uri)
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Cover)
      .borderRadius(Theme.radius.sm)
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      if (this.isDemo() || this.uri.length === 0) {
        this.demoTile()
      } else {
        this.realImage()
      }
      if (this.badge.length > 0) {
        Text(this.badge)
          .fontSize(Theme.font.micro)
          .fontColor(Theme.color.textOnPrimary)
          .backgroundColor(Theme.color.primary)
          .borderRadius(Theme.radius.xs)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin(5)
      }
    }
    .width('100%')
    .aspectRatio(1)
    .clip(true)
    .borderRadius(Theme.radius.sm)
    .border({ width: 1, color: Theme.color.borderSubtle })
    .onClick(() => { if (this.onTap) this.onTap() })
  }
}
