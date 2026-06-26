// ============================================================
// QuickActionTile —— 首页快捷操作格子（图标 + 文案）
// entry/src/main/ets/components/QuickActionTile.ets
// ============================================================

import { Theme } from '../common/Theme'

@Component
export struct QuickActionTile {
  @Prop glyph: string = ''
  @Prop label: string = ''
  @Prop glyphColor: ResourceColor = Theme.color.primary
  onTap?: () => void

  @State private pressed: boolean = false

  build() {
    Column({ space: 8 }) {
      Text(this.glyph)
        .fontSize(19)
        .fontColor(this.glyphColor)
        .width(40).height(40).textAlign(TextAlign.Center)
        .borderRadius(20)
        .backgroundColor(Theme.color.bgCardElevated)
        .border({ width: 1, color: Theme.color.borderSubtle })
      Text(this.label)
        .fontSize(Theme.font.micro + 1)
        .fontColor(Theme.color.textSecondary)
        .maxLines(1)
    }
    .layoutWeight(1)
    .padding({ top: 13, bottom: 13, left: 4, right: 4 })
    .backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.color.borderDefault })
    .shadow(Theme.shadow.card)
    .scale({ x: this.pressed ? 0.96 : 1, y: this.pressed ? 0.96 : 1 })
    .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) this.pressed = true
      else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressed = false
    })
    .onClick(() => { if (this.onTap) this.onTap() })
  }
}
