// ============================================================
// AppChip —— 筛选/选择胶囊（选中=琥珀实心，未选=描边）
// entry/src/main/ets/components/AppChip.ets
// ============================================================

import { Theme } from '../common/Theme'

@Component
export struct AppChip {
  @Prop label: string = ''
  @Prop leadingGlyph: string = ''
  @Prop selected: boolean = false
  onTap?: () => void

  build() {
    Row({ space: 4 }) {
      if (this.leadingGlyph.length > 0) {
        Text(this.leadingGlyph)
          .fontSize(Theme.font.footnote)
          .fontColor(this.selected ? Theme.color.textOnPrimary : Theme.color.textTertiary)
      }
      Text(this.label)
        .fontSize(Theme.font.footnote)
        .fontColor(this.selected ? Theme.color.textOnPrimary : Theme.color.textTertiary)
        .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Normal)
    }
    .padding({ left: 13, right: 13, top: 6, bottom: 6 })
    .backgroundColor(this.selected ? Theme.color.primary : Theme.color.bgCard)
    .borderRadius(Theme.radius.pill)
    .border({ width: this.selected ? 0 : 1, color: Theme.color.borderDefault })
    .onClick(() => { if (this.onTap) this.onTap() })
  }
}
