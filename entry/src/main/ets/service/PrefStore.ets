// ============================================================
// 宠忆时光 - Preferences 本地 KV 封装
// entry/src/main/ets/service/PrefStore.ets
// ============================================================

import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppConstants } from '../common/Constants'

const TAG: string = 'ChongYiPref'
const DOMAIN: number = 0xFF00

export class PrefStore {
  private static pref: preferences.Preferences | null = null

  static init(context: common.UIAbilityContext): void {
    if (PrefStore.pref) return
    try {
      PrefStore.pref = preferences.getPreferencesSync(context, { name: AppConstants.PREF_NAME })
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'pref init failed: ' + JSON.stringify(e))
    }
  }

  static getBool(key: string, def: boolean): boolean {
    if (!PrefStore.pref) return def
    return PrefStore.pref.getSync(key, def) as boolean
  }

  static setBool(key: string, value: boolean): void {
    if (!PrefStore.pref) return
    PrefStore.pref.putSync(key, value)
    PrefStore.pref.flush()
  }

  static getNumber(key: string, def: number): number {
    if (!PrefStore.pref) return def
    return PrefStore.pref.getSync(key, def) as number
  }

  static setNumber(key: string, value: number): void {
    if (!PrefStore.pref) return
    PrefStore.pref.putSync(key, value)
    PrefStore.pref.flush()
  }

  static getString(key: string, def: string): string {
    if (!PrefStore.pref) return def
    return PrefStore.pref.getSync(key, def) as string
  }

  static setString(key: string, value: string): void {
    if (!PrefStore.pref) return
    PrefStore.pref.putSync(key, value)
    PrefStore.pref.flush()
  }

  // ── 业务便捷方法 ──
  static currentPetId(): number {
    return PrefStore.getNumber(AppConstants.KEY_CURRENT_PET_ID, 0)
  }
  static setCurrentPetId(id: number): void {
    PrefStore.setNumber(AppConstants.KEY_CURRENT_PET_ID, id)
  }
  static markOnboarded(): void {
    PrefStore.setBool(AppConstants.KEY_ONBOARDING_DONE, true)
  }
  static startSession(phone: string): void {
    PrefStore.setBool(AppConstants.KEY_SESSION_ACTIVE, true)
    PrefStore.setString(AppConstants.KEY_PHONE, phone)
  }
  static endSession(): void {
    PrefStore.setBool(AppConstants.KEY_SESSION_ACTIVE, false)
  }
}
