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

    // 第一只宠物：柯基犬「奶糖」
    const dog = new Pet()
    dog.name = '奶糖'
    dog.species = 'dog'
    dog.breed = '柯基'
    dog.gender = 'female'
    dog.birthday = DateUtil.addMonths(Date.now(), -26)
    dog.weightKg = 12.3
    const dogId: number = await PetStore.insertPet(dog)
    await SeedData.seedForPet(dogId, dog.name, dog.birthday)

    // 第二只宠物：英短猫「可可」（简单数据，让宠物选择器更丰富）
    const cat = new Pet()
    cat.name = '可可'
    cat.species = 'cat'
    cat.breed = '英国短毛猫'
    cat.gender = 'male'
    cat.birthday = DateUtil.addMonths(Date.now(), -14)
    cat.weightKg = 4.8
    const catId: number = await PetStore.insertPet(cat)
    await SeedData.seedCat(catId, cat.name, cat.birthday)

    return dogId
  }

  static async seedForPet(petId: number, petName: string, birthday: number): Promise<void> {
    const now: number = Date.now()
    const day: number = AppConstants.DAY_MS

    // ── 示例里程碑（覆盖全部 5 种类型，并跨年份方便演示时间轴分组）──
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

    const m4 = new Milestone()
    m4.petId = petId; m4.type = 'checkup'; m4.title = '年度体检'
    m4.date = DateUtil.addMonths(now, -13); m4.note = '安心宠物医疗中心（三星）'
    await PetStore.insertMilestone(m4)

    const m5 = new Milestone()
    m5.petId = petId; m5.type = 'custom'; m5.title = '学会了"坐下"口令'
    m5.date = now - 40 * day; m5.note = '口令训练'
    await PetStore.insertMilestone(m5)

    // ── 示例健康提醒（覆盖逾期/临近/正常/已完成四种状态）──
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

    const h4 = new HealthReminder()
    h4.petId = petId; h4.type = 'other'; h4.title = '洗澡美容'
    h4.dueDate = now + 10 * day; h4.cycleMonths = 1; h4.done = false; h4.notify = true
    await PetStore.insertHealth(h4)

    const h5 = new HealthReminder()
    h5.petId = petId; h5.type = 'deworm'; h5.title = '上次驱虫'
    h5.dueDate = now - 90 * day; h5.cycleMonths = 3; h5.done = true; h5.notify = true
    await PetStore.insertHealth(h5)

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

  private static async seedCat(petId: number, name: string, birthday: number): Promise<void> {
    const now: number = Date.now()
    const day: number = AppConstants.DAY_MS

    const m1 = new Milestone()
    m1.petId = petId; m1.type = 'birthday'; m1.title = name + ' 的生日'
    m1.date = birthday; m1.note = '家里庆生'
    await PetStore.insertMilestone(m1)

    const m2 = new Milestone()
    m2.petId = petId; m2.type = 'vaccine'; m2.title = '猫三联接种'
    m2.date = now - 18 * day; m2.note = '乐宠宠物诊所'
    await PetStore.insertMilestone(m2)

    const m3 = new Milestone()
    m3.petId = petId; m3.type = 'checkup'; m3.title = '首次体检'
    m3.date = DateUtil.addMonths(now, -12); m3.note = '安心宠物医疗中心'
    await PetStore.insertMilestone(m3)

    const h1 = new HealthReminder()
    h1.petId = petId; h1.type = 'vaccine'; h1.title = '猫三联加强'
    h1.dueDate = now + 15 * day; h1.cycleMonths = 12; h1.done = false; h1.notify = true
    await PetStore.insertHealth(h1)

    const h2 = new HealthReminder()
    h2.petId = petId; h2.type = 'deworm'; h2.title = '体内驱虫'
    h2.dueDate = now - 5 * day; h2.cycleMonths = 3; h2.done = false; h2.notify = true
    await PetStore.insertHealth(h2)

    const weights: number[] = [3.8, 4.1, 4.4, 4.6, 4.8]
    for (let i = 0; i < weights.length; i++) {
      const w = new WeightEntry()
      w.petId = petId; w.weightKg = weights[i]
      w.recordedAt = DateUtil.addMonths(now, -(weights.length - 1 - i))
      await PetStore.insertWeight(w)
    }

    const cats: string[] = ['daily', 'food', 'daily', 'outdoor', 'other', 'daily']
    for (let i = 0; i < cats.length; i++) {
      const p = new PhotoItem()
      p.petId = petId; p.uri = 'demo://' + cats[i]; p.category = cats[i]
      p.takenAt = now - i * AppConstants.DAY_MS
      await PetStore.insertPhoto(p)
    }
  }

  private static async seedAlbum(petId: number): Promise<void> {
    const now: number = Date.now()
    // 覆盖全部 5 个相册分类，凑满 3x3 九宫格；uri 以 demo:// 开头让 PhotoTile 渲染分类色占位图
    const cats: string[] = ['daily', 'outdoor', 'hospital', 'food', 'daily', 'other', 'outdoor', 'daily', 'food']
    for (let i = 0; i < cats.length; i++) {
      const p = new PhotoItem()
      p.petId = petId
      p.uri = 'demo://' + cats[i]
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
