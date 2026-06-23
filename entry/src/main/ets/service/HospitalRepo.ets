// ============================================================
// 宠忆时光 - 宠医星医院仓库（只读，来自 rawfile/hospitals.json）
// entry/src/main/ets/service/HospitalRepo.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { util } from '@kit.ArkTS'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Hospital } from '../model/PetModels'

const TAG: string = 'ChongYiHospital'
const DOMAIN: number = 0xFF00

export class HospitalRepo {
  private static cache: Hospital[] = []

  static async load(context: common.UIAbilityContext): Promise<Hospital[]> {
    if (HospitalRepo.cache.length > 0) return HospitalRepo.cache
    try {
      const bytes: Uint8Array = await context.resourceManager.getRawFileContent('hospitals.json')
      const decoder = util.TextDecoder.create('utf-8')
      const text: string = decoder.decodeToString(bytes)
      const parsed = JSON.parse(text) as Hospital[]
      HospitalRepo.cache = parsed
      return parsed
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'load hospitals failed: ' + JSON.stringify(e))
      return []
    }
  }

  static cached(): Hospital[] {
    return HospitalRepo.cache
  }

  static byId(id: string): Hospital | null {
    for (let i = 0; i < HospitalRepo.cache.length; i++) {
      if (HospitalRepo.cache[i].id === id) return HospitalRepo.cache[i]
    }
    return null
  }

  static filterByStar(star: number): Hospital[] {
    if (star <= 0) return HospitalRepo.cache
    return HospitalRepo.cache.filter((h: Hospital) => h.star === star)
  }
}
