// ============================================================
// PetAvatar —— 宠物圆形头像（图片或物种 emoji 占位）
// entry/src/main/ets/components/PetAvatar.ets
// ============================================================

import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'

@Component
export struct PetAvatar {
  @Prop name: string = ''
  @Prop species: string = 'dog'
  @Prop avatarUri: string = ''
  @Prop active: boolean = false
  @Prop avatarSize: number = 52
  @Prop showLabel: boolean = true
  onTap?: () => void

  private speciesGlyph(): string {
    if (this.species === 'cat') return Icons.cat
    if (this.species === 'other') return Icons.paw
    return Icons.dog
  }

  private ringColor(): ResourceColor {
    return this.active ? Theme.color.primary : Theme.color.borderDefault
  }

  build() {
    Column({ space: 5 }) {
      Stack() {
        if (this.avatarUri.length > 0) {
          Image(this.avatarUri)
            .width(this.avatarSize)
            .height(this.avatarSize)
            .borderRadius(this.avatarSize / 2)
            .objectFit(ImageFit.Cover)
        } else {
          Text(this.speciesGlyph())
            .fontSize(this.avatarSize * 0.46)
            .textAlign(TextAlign.Center)
        }
      }
      .width(this.avatarSize)
      .height(this.avatarSize)
      .borderRadius(this.avatarSize / 2)
      .backgroundColor(Theme.color.bgCard)
      .border({ width: 2, color: this.ringColor() })
      .alignContent(Alignment.Center)

      if (this.showLabel) {
        Text(this.name)
          .fontSize(Theme.font.footnote)
          .fontColor(this.active ? Theme.color.primary : Theme.color.textTertiary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .onClick(() => { if (this.onTap) this.onTap() })
  }
}
