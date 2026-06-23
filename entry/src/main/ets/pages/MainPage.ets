// ============================================================
// 宠忆时光 - 主壳页（自定义底部导航 + 四个 Tab）
// entry/src/main/ets/pages/MainPage.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { Theme } from '../common/Theme'
import { Icons } from '../common/Icons'
import { AppInit } from '../service/AppInit'
import { HomeTab } from './tabs/HomeTab'
import { AlbumTab } from './tabs/AlbumTab'
import { HealthTab } from './tabs/HealthTab'
import { ProfileTab } from './tabs/ProfileTab'

@Entry
@Component
struct MainPage {
  @State activeTab: number = 0
  @State tick: number = 0

  async aboutToAppear(): Promise<void> {
    const ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    await AppInit.ensure(ctx)
  }

  // 每次页面回到前台（含从子页面 back）刷新当前 Tab 数据
  onPageShow(): void {
    this.tick += 1
  }

  private switchTab(i: number): void {
    this.activeTab = i
    this.tick += 1
  }

  @Builder navItem(index: number, glyph: string, label: string) {
    Column({ space: 2 }) {
      Text(glyph).fontSize(20)
        .fontColor(this.activeTab === index ? Theme.color.primary : Theme.color.textDisabled)
      Text(label).fontSize(Theme.font.micro)
        .fontColor(this.activeTab === index ? Theme.color.primary : Theme.color.textDisabled)
    }
    .width(60).justifyContent(FlexAlign.Center)
    .onClick(() => this.switchTab(index))
  }

  build() {
    Column() {
      // ── Tab 内容区 ──
      Column() {
        if (this.activeTab === 0) {
          HomeTab({ tick: this.tick, switchTab: (i: number): void => this.switchTab(i) })
        } else if (this.activeTab === 1) {
          AlbumTab({ tick: this.tick })
        } else if (this.activeTab === 2) {
          HealthTab({ tick: this.tick })
        } else {
          ProfileTab({ tick: this.tick })
        }
      }
      .layoutWeight(1)
      .width('100%')

      // ── 底部导航 ──
      Row() {
        this.navItem(0, Icons.home, '首页')
        this.navItem(1, Icons.album, '相册')
        this.navItem(2, Icons.health, '健康')
        this.navItem(3, Icons.mine, '我的')
      }
      .width('100%')
      .height(Theme.size.tabBarHeight)
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Theme.color.bgDeep)
      .border({ width: { top: 1 }, color: Theme.color.borderDefault })
      .padding({ bottom: 6 })
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.color.bgBase)
  }
}
