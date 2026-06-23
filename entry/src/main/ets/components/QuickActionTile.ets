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

  build() {
    Column({ space: 6 }) {
      Text(this.glyph)
        .fontSize(21)
        .fontColor(this.glyphColor)
      Text(this.label)
        .fontSize(Theme.font.micro + 1)
        .fontColor(Theme.color.textSecondary)
        .maxLines(1)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12, left: 4, right: 4 })
    .backgroundColor(Theme.color.bgCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.color.borderDefault })
    .onClick(() => { if (this.onTap) this.onTap() })
  }
}
