// ============================================================
// 宠忆时光 - 首次建档后的示例数据（让 App 立刻可演示）
// entry/src/main/ets/service/SeedData.ets
//
// 在用户完成 PetSetupPage 建档后调用，把示例里程碑/健康/体重
// 挂到用户真实创建的宠物上。
// ============================================================

import { PetStore } from './PetStore'
import { DateUtil } from '../common/DateUtil'
import { AppConstants } from '../common/Constants'
import { Pet, Milestone, PhotoItem, HealthReminder, WeightEntry } from '../model/PetModels'

export class SeedData {
  static async seedDemoIfEmpty(): Promise<number> {
    const count: number = await PetStore.countPets()
    if (count > 0) {
      return PrefStoreFallback.currentPetIdOrFirst()
    }

    const demo = new Pet()
    demo.name = '奶糖'
    demo.species = 'dog'
    demo.breed = '柯基'
    demo.gender = 'female'
    demo.birthday = DateUtil.addMonths(Date.now(), -26)
    demo.weightKg = 12.3
    const petId: number = await PetStore.insertPet(demo)
    await SeedData.seedForPet(petId, demo.name, demo.birthday)
    return petId
  }

  static async seedForPet(petId: number, petName: string, birthday: number): Promise<void> {
    const now: number = Date.now()
    const day: number = AppConstants.DAY_MS

    // ── 示例里程碑 ──
    const m1 = new Milestone()
    m1.petId = petId; m1.type = 'birthday'; m1.title = petName + ' 的生日'
    m1.date = birthday > 0 ? birthday : now - 15 * day; m1.note = '家里'
    await PetStore.insertMilestone(m1)

    const m2 = new Milestone()
    m2.petId = petId; m2.type = 'vaccine'; m2.title = '三联疫苗接种'
    m2.date = now - 27 * day; m2.note = '爱宠动物医院（三星）'
    await PetStore.insertMilestone(m2)

    const m3 = new Milestone()
    m3.petId = petId; m3.type = 'trip'; m3.title = '第一次去海边'
    m3.date = now - 62 * day; m3.note = '手动记录'
    await PetStore.insertMilestone(m3)

    // ── 示例健康提醒 ──
    const h1 = new HealthReminder()
    h1.petId = petId; h1.type = 'deworm'; h1.title = '驱虫药投喂'
    h1.dueDate = now - 3 * day; h1.cycleMonths = 3; h1.done = false; h1.notify = true
    await PetStore.insertHealth(h1)

    const h2 = new HealthReminder()
    h2.petId = petId; h2.type = 'vaccine'; h2.title = '三联疫苗加强'
    h2.dueDate = now + 3 * day; h2.cycleMonths = 12; h2.done = false; h2.notify = true
    await PetStore.insertHealth(h2)

    const h3 = new HealthReminder()
    h3.petId = petId; h3.type = 'checkup'; h3.title = '年度体检'
    h3.dueDate = now + 45 * day; h3.cycleMonths = 12; h3.done = false; h3.notify = true
    await PetStore.insertHealth(h3)

    // ── 示例体重轨迹 ──
    const weights: number[] = [10.5, 11.2, 11.8, 12.0, 12.2, 12.3]
    for (let i = 0; i < weights.length; i++) {
      const w = new WeightEntry()
      w.petId = petId
      w.weightKg = weights[i]
      w.recordedAt = DateUtil.addMonths(now, -(weights.length - 1 - i))
      await PetStore.insertWeight(w)
    }

    await SeedData.seedAlbum(petId)
  }

  private static async seedAlbum(petId: number): Promise<void> {
    const now: number = Date.now()
    const cats: string[] = ['daily', 'outdoor', 'hospital', 'food', 'daily', 'other']
    for (let i = 0; i < cats.length; i++) {
      const p = new PhotoItem()
      p.petId = petId
      p.uri = ''
      p.category = cats[i]
      p.takenAt = now - i * AppConstants.DAY_MS
      await PetStore.insertPhoto(p)
    }
  }
}

class PrefStoreFallback {
  static async currentPetIdOrFirst(): Promise<number> {
    const pets: Pet[] = await PetStore.listPets()
    if (pets.length === 0) return 0
    return pets[0].id
  }
}
