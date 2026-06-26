// ============================================================
// 宠忆时光 - 统一初始化入口（页面 aboutToAppear 调用）
// entry/src/main/ets/service/AppInit.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { Database } from './Database'
import { PrefStore } from './PrefStore'

export class AppInit {
  private static done: boolean = false

  static async ensure(context: common.UIAbilityContext): Promise<void> {
    PrefStore.init(context)
    if (!Database.isReady()) {
      await Database.init(context)
    }
    AppInit.done = true
  }

  static isDone(): boolean {
    return AppInit.done
  }
}
