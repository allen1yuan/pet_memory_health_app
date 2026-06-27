// ============================================================
// BrandLogo —— 宠忆时光品牌 mark（爱心）
// entry/src/main/ets/components/BrandLogo.ets
//
// withGlow：心形背后一圈柔和呼吸光晕（径向渐变 + 缓慢脉动），
// 颜色极浅、只取一点暖橘调，避免在白底上糊成一块"脏"色斑。
// 注意：ArkUI hex 颜色 #AARRGGBB（alpha 在前）
// ============================================================

import { Theme } from '../common/Theme'

@Component
export struct BrandLogo {
  @Prop logoSize: number = 32
  @Prop withGlow: boolean = false
  @State private pulse: number = 0

  // 爱心 path（viewBox 100x100）
  private readonly heartPath: string =
    'M50 30 C50 12 24 8 16 28 C8 48 30 66 50 84 C70 66 92 48 84 28 C76 8 50 12 50 30 Z'

  aboutToAppear(): void {
    if (!this.withGlow) return
    animateTo({
      duration: 2200,
      curve: Curve.EaseInOut,
      iterations: -1,
      playMode: PlayMode.Alternate
    }, () => {
      this.pulse = 1
    })
  }

  private getShadow(): ShadowOptions | undefined {
    if (!this.withGlow) return undefined
    return {
      radius: 12,
      color: '#26F2843D',
      offsetX: 0,
      offsetY: 5
    }
  }

  build() {
    Stack() {
      if (this.withGlow) {
        Column()
          .width(this.logoSize * 2.2)
          .height(this.logoSize * 2.2)
          .borderRadius(this.logoSize * 1.1)
          .radialGradient({
            center: ['50%', '50%'],
            radius: '50%',
            colors: [['#3CFFD9A6', 0], ['#00FFD9A6', 1]]
          })
          .scale({ x: 1 + this.pulse * 0.16, y: 1 + this.pulse * 0.16 })
          .opacity(0.65 + this.pulse * 0.35)
          .hitTestBehavior(HitTestMode.None)
      }
      Path()
        .width(this.logoSize)
        .height(this.logoSize)
        .commands(this.heartPath)
        .fill(Theme.color.primary)
        .stroke(Color.Transparent)
        .shadow(this.getShadow())
    }
    .width(this.withGlow ? this.logoSize * 2.2 : this.logoSize)
    .height(this.withGlow ? this.logoSize * 2.2 : this.logoSize)
    .alignContent(Alignment.Center)
    .hitTestBehavior(HitTestMode.None)
  }
}
