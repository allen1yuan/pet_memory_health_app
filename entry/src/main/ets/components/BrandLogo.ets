// ============================================================
// BrandLogo —— 宠忆时光品牌 mark（爱心）
// entry/src/main/ets/components/BrandLogo.ets
//
// 注意：ArkUI hex 颜色 #AARRGGBB（alpha 在前）
// ============================================================

import { Theme } from '../common/Theme'

@Component
export struct BrandLogo {
  @Prop logoSize: number = 32
  @Prop withGlow: boolean = false

  // 爱心 path（viewBox 100x100）
  private readonly heartPath: string =
    'M50 30 C50 12 24 8 16 28 C8 48 30 66 50 84 C70 66 92 48 84 28 C76 8 50 12 50 30 Z'

  private getShadow(): ShadowOptions | undefined {
    if (!this.withGlow) return undefined
    return {
      radius: this.logoSize * 0.6,
      color: '#99F28A3D',
      offsetX: 0,
      offsetY: 0
    }
  }

  build() {
    Stack() {
      if (this.withGlow) {
        Column()
          .width(this.logoSize * 2)
          .height(this.logoSize * 2)
          .borderRadius(this.logoSize)
          .backgroundColor(Theme.color.glowPrimaryLg)
          .blur(40)
      }
      Path()
        .width(this.logoSize)
        .height(this.logoSize)
        .commands(this.heartPath)
        .fill(Theme.color.primary)
        .stroke(Color.Transparent)
        .shadow(this.getShadow())
    }
    .width(this.withGlow ? this.logoSize * 2 : this.logoSize)
    .height(this.withGlow ? this.logoSize * 2 : this.logoSize)
    .alignContent(Alignment.Center)
  }
}
