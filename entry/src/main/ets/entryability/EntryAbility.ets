// ============================================================
// 宠忆时光 HarmonyOS - 主入口 Ability
// entry/src/main/ets/entryability/EntryAbility.ets
//
// 首屏路由决策（本地，无服务端）：
//   未登录            → LoginPage
//   已登录但未建档     → PetSetupPage
//   已登录且已建档     → MainPage
// ============================================================

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
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
        isStatusBarLightIcon: true,
        isNavigationBarLightIcon: true,
        statusBarContentColor: '#CCFFFFFF',
        navigationBarContentColor: '#CCFFFFFF'
      })
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Apply transparent system bars failed: ' + JSON.stringify(err))
    }
  }

  private decideFirstRoute(): string {
    try {
      const pref = preferences.getPreferencesSync(this.context, { name: AppConstants.PREF_NAME })
      const session: boolean = pref.getSync(AppConstants.KEY_SESSION_ACTIVE, false) as boolean
      const onboarded: boolean = pref.getSync(AppConstants.KEY_ONBOARDING_DONE, false) as boolean
      if (!session) return AppConstants.PAGE_LOGIN
      if (!onboarded) return AppConstants.PAGE_PET_SETUP
      return AppConstants.PAGE_MAIN
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Preferences read error, fallback to LoginPage')
      return AppConstants.PAGE_LOGIN
    }
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
