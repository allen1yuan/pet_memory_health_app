// ============================================================
// 宠忆时光 HarmonyOS - 主入口 Ability
// entry/src/main/ets/entryability/EntryAbility.ets
//
// 首屏路由决策（本地，无服务端）：
//   固定直达 MainPage —— 免登录 / 免建档演示模式。
//   HomeTab 首次加载时若本地没有任何宠物，会自动播种本地演示数据
//   （见 HomeTab.reload() / SeedData.seedDemoIfEmpty()）。
//   LoginPage / PetSetupPage 仍然保留、可正常使用，只是不再是冷启动的强制网关——
//   「我的」页的"退出登录"仍会跳回 LoginPage，可手动走完整登录/建档流程。
// ============================================================

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { AppConstants } from '../common/Constants'

const TAG: string = 'ChongYi'
const DOMAIN: number = 0xFF00

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, '宠忆时光 onCreate')
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '宠忆时光 onDestroy')
  }

  private applyTransparentSystemBars(windowStage: window.WindowStage): void {
    try {
      const mainWindow = windowStage.getMainWindowSync()
      mainWindow.setWindowLayoutFullScreen(true)
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        isStatusBarLightIcon: false,
        isNavigationBarLightIcon: false,
        statusBarContentColor: '#CC2B1F17',
        navigationBarContentColor: '#CC2B1F17'
      })
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Apply transparent system bars failed: ' + JSON.stringify(err))
    }
  }

  private decideFirstRoute(): string {
    // 演示模式：冷启动直接进 MainPage，免登录 / 免建档。
    // 本地是否已有宠物数据由 HomeTab 自己兜底（没有就自动播种假数据）。
    return AppConstants.PAGE_MAIN
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, '宠忆时光 onWindowStageCreate')
    this.applyTransparentSystemBars(windowStage)

    const route: string = this.decideFirstRoute()
    windowStage.loadContent(route, (err) => {
      if (err && err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load ' + route + ': ' + JSON.stringify(err))
        windowStage.loadContent(AppConstants.PAGE_LOGIN)
        return
      }
      hilog.info(DOMAIN, TAG, route + ' loaded')
    })
  }

  onWindowStageDestroy(): void {}
  onForeground(): void {}
  onBackground(): void {}
}
