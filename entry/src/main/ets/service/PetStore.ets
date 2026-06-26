// ============================================================
// 宠忆时光 - 数据访问层（DAO）
// entry/src/main/ets/service/PetStore.ets
//
// 封装 pets / milestones / photos / health_reminders / weights 的 CRUD。
// 数组字段（里程碑照片）以管道符连接序列化，避免 JSON 类型转换问题。
// ============================================================

import { relationalStore } from '@kit.ArkData'
import { Database } from './Database'
import { DateUtil } from '../common/DateUtil'
import { Pet, Milestone, PhotoItem, HealthReminder, WeightEntry } from '../model/PetModels'

const SEP: string = '|#|'

function joinUris(uris: string[]): string {
  return uris.join(SEP)
}
function splitUris(s: string): string[] {
  if (!s || s.length === 0) return []
  return s.split(SEP).filter((x: string) => x.length > 0)
}

export class PetStore {
  // ════════════════ 宠物 ════════════════
  static async insertPet(pet: Pet): Promise<number> {
    const vb: relationalStore.ValuesBucket = {
      'name': pet.name, 'species': pet.species, 'breed': pet.breed,
      'birthday': pet.birthday, 'gender': pet.gender, 'weight': pet.weightKg,
      'avatar': pet.avatarUri, 'created_at': Date.now()
    }
    return await Database.store().insert('pets', vb)
  }

  static async updatePet(pet: Pet): Promise<void> {
    const vb: relationalStore.ValuesBucket = {
      'name': pet.name, 'species': pet.species, 'breed': pet.breed,
      'birthday': pet.birthday, 'gender': pet.gender, 'weight': pet.weightKg,
      'avatar': pet.avatarUri
    }
    const pred = new relationalStore.RdbPredicates('pets')
    pred.equalTo('id', pet.id)
    await Database.store().update(vb, pred)
  }

  static async listPets(): Promise<Pet[]> {
    const pred = new relationalStore.RdbPredicates('pets')
    pred.orderByAsc('created_at')
    const rs = await Database.store().query(pred,
      ['id', 'name', 'species', 'breed', 'birthday', 'gender', 'weight', 'avatar', 'created_at'])
    const list: Pet[] = []
    while (rs.goToNextRow()) {
      const p = new Pet()
      p.id = rs.getLong(rs.getColumnIndex('id'))
      p.name = rs.getString(rs.getColumnIndex('name'))
      p.species = rs.getString(rs.getColumnIndex('species'))
      p.breed = rs.getString(rs.getColumnIndex('breed'))
      p.birthday = rs.getLong(rs.getColumnIndex('birthday'))
      p.gender = rs.getString(rs.getColumnIndex('gender'))
      p.weightKg = rs.getDouble(rs.getColumnIndex('weight'))
      p.avatarUri = rs.getString(rs.getColumnIndex('avatar'))
      p.createdAt = rs.getLong(rs.getColumnIndex('created_at'))
      list.push(p)
    }
    rs.close()
    return list
  }

  static async getPet(id: number): Promise<Pet | null> {
    const pred = new relationalStore.RdbPredicates('pets')
    pred.equalTo('id', id)
    const rs = await Database.store().query(pred,
      ['id', 'name', 'species', 'breed', 'birthday', 'gender', 'weight', 'avatar', 'created_at'])
    let pet: Pet | null = null
    if (rs.goToNextRow()) {
      pet = new Pet()
      pet.id = rs.getLong(rs.getColumnIndex('id'))
      pet.name = rs.getString(rs.getColumnIndex('name'))
      pet.species = rs.getString(rs.getColumnIndex('species'))
      pet.breed = rs.getString(rs.getColumnIndex('breed'))
      pet.birthday = rs.getLong(rs.getColumnIndex('birthday'))
      pet.gender = rs.getString(rs.getColumnIndex('gender'))
      pet.weightKg = rs.getDouble(rs.getColumnIndex('weight'))
      pet.avatarUri = rs.getString(rs.getColumnIndex('avatar'))
      pet.createdAt = rs.getLong(rs.getColumnIndex('created_at'))
    }
    rs.close()
    return pet
  }

  static async countPets(): Promise<number> {
    const pred = new relationalStore.RdbPredicates('pets')
    const rs = await Database.store().query(pred, ['id'])
    const n: number = rs.rowCount
    rs.close()
    return n < 0 ? 0 : n
  }

  // ════════════════ 里程碑 ════════════════
  static async insertMilestone(m: Milestone): Promise<number> {
    const vb: relationalStore.ValuesBucket = {
      'pet_id': m.petId, 'type': m.type, 'title': m.title,
      'date': m.date, 'note': m.note, 'photos': joinUris(m.photoUris)
    }
    return await Database.store().insert('milestones', vb)
  }

  static async listMilestones(petId: number): Promise<Milestone[]> {
    const pred = new relationalStore.RdbPredicates('milestones')
    pred.equalTo('pet_id', petId)
    pred.orderByDesc('date')
    const rs = await Database.store().query(pred,
      ['id', 'pet_id', 'type', 'title', 'date', 'note', 'photos'])
    const list: Milestone[] = []
    while (rs.goToNextRow()) {
      const m = new Milestone()
      m.id = rs.getLong(rs.getColumnIndex('id'))
      m.petId = rs.getLong(rs.getColumnIndex('pet_id'))
      m.type = rs.getString(rs.getColumnIndex('type'))
      m.title = rs.getString(rs.getColumnIndex('title'))
      m.date = rs.getLong(rs.getColumnIndex('date'))
      m.note = rs.getString(rs.getColumnIndex('note'))
      m.photoUris = splitUris(rs.getString(rs.getColumnIndex('photos')))
      list.push(m)
    }
    rs.close()
    return list
  }

  static async deleteMilestone(id: number): Promise<void> {
    const pred = new relationalStore.RdbPredicates('milestones')
    pred.equalTo('id', id)
    await Database.store().delete(pred)
  }

  // ════════════════ 相册 ════════════════
  static async insertPhoto(p: PhotoItem): Promise<number> {
    const vb: relationalStore.ValuesBucket = {
      'pet_id': p.petId, 'uri': p.uri, 'category': p.category, 'taken_at': p.takenAt
    }
    return await Database.store().insert('photos', vb)
  }

  static async listPhotos(petId: number, category: string): Promise<PhotoItem[]> {
    const pred = new relationalStore.RdbPredicates('photos')
    pred.equalTo('pet_id', petId)
    if (category.length > 0 && category !== 'all') {
      pred.equalTo('category', category)
    }
    pred.orderByDesc('taken_at')
    const rs = await Database.store().query(pred, ['id', 'pet_id', 'uri', 'category', 'taken_at'])
    const list: PhotoItem[] = []
    while (rs.goToNextRow()) {
      const p = new PhotoItem()
      p.id = rs.getLong(rs.getColumnIndex('id'))
      p.petId = rs.getLong(rs.getColumnIndex('pet_id'))
      p.uri = rs.getString(rs.getColumnIndex('uri'))
      p.category = rs.getString(rs.getColumnIndex('category'))
      p.takenAt = rs.getLong(rs.getColumnIndex('taken_at'))
      list.push(p)
    }
    rs.close()
    return list
  }

  static async countPhotos(petId: number): Promise<number> {
    const pred = new relationalStore.RdbPredicates('photos')
    pred.equalTo('pet_id', petId)
    const rs = await Database.store().query(pred, ['id'])
    const n: number = rs.rowCount
    rs.close()
    return n < 0 ? 0 : n
  }

  static async updatePhotoCategory(id: number, category: string): Promise<void> {
    const vb: relationalStore.ValuesBucket = { 'category': category }
    const pred = new relationalStore.RdbPredicates('photos')
    pred.equalTo('id', id)
    await Database.store().update(vb, pred)
  }

  static async deletePhoto(id: number): Promise<void> {
    const pred = new relationalStore.RdbPredicates('photos')
    pred.equalTo('id', id)
    await Database.store().delete(pred)
  }

  // ════════════════ 健康提醒 ════════════════
  static async insertHealth(h: HealthReminder): Promise<number> {
    const vb: relationalStore.ValuesBucket = {
      'pet_id': h.petId, 'type': h.type, 'title': h.title, 'due_date': h.dueDate,
      'cycle_months': h.cycleMonths, 'done': h.done ? 1 : 0, 'notify': h.notify ? 1 : 0
    }
    return await Database.store().insert('health_reminders', vb)
  }

  static async listHealth(petId: number): Promise<HealthReminder[]> {
    const pred = new relationalStore.RdbPredicates('health_reminders')
    pred.equalTo('pet_id', petId)
    pred.orderByAsc('due_date')
    const rs = await Database.store().query(pred,
      ['id', 'pet_id', 'type', 'title', 'due_date', 'cycle_months', 'done', 'notify'])
    const list: HealthReminder[] = []
    while (rs.goToNextRow()) {
      const h = new HealthReminder()
      h.id = rs.getLong(rs.getColumnIndex('id'))
      h.petId = rs.getLong(rs.getColumnIndex('pet_id'))
      h.type = rs.getString(rs.getColumnIndex('type'))
      h.title = rs.getString(rs.getColumnIndex('title'))
      h.dueDate = rs.getLong(rs.getColumnIndex('due_date'))
      h.cycleMonths = rs.getLong(rs.getColumnIndex('cycle_months'))
      h.done = rs.getLong(rs.getColumnIndex('done')) === 1
      h.notify = rs.getLong(rs.getColumnIndex('notify')) === 1
      h.status = h.done ? 'ok' : DateUtil.reminderStatus(h.dueDate)
      list.push(h)
    }
    rs.close()
    return list
  }

  static async markHealthDone(id: number): Promise<void> {
    const vb: relationalStore.ValuesBucket = { 'done': 1 }
    const pred = new relationalStore.RdbPredicates('health_reminders')
    pred.equalTo('id', id)
    await Database.store().update(vb, pred)
  }

  // ════════════════ 体重 ════════════════
  static async insertWeight(w: WeightEntry): Promise<number> {
    const vb: relationalStore.ValuesBucket = {
      'pet_id': w.petId, 'weight': w.weightKg, 'recorded_at': w.recordedAt
    }
    return await Database.store().insert('weights', vb)
  }

  static async listWeights(petId: number): Promise<WeightEntry[]> {
    const pred = new relationalStore.RdbPredicates('weights')
    pred.equalTo('pet_id', petId)
    pred.orderByAsc('recorded_at')
    const rs = await Database.store().query(pred, ['id', 'pet_id', 'weight', 'recorded_at'])
    const list: WeightEntry[] = []
    while (rs.goToNextRow()) {
      const w = new WeightEntry()
      w.id = rs.getLong(rs.getColumnIndex('id'))
      w.petId = rs.getLong(rs.getColumnIndex('pet_id'))
      w.weightKg = rs.getDouble(rs.getColumnIndex('weight'))
      w.recordedAt = rs.getLong(rs.getColumnIndex('recorded_at'))
      list.push(w)
    }
    rs.close()
    return list
  }
}
