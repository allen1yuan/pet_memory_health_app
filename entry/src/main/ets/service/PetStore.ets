// ============================================================
// 宠忆时光 - 数据访问层（DAO）
// entry/src/main/ets/service/PetStore.ets
//
// 优先使用 relationalStore（RDB）。当 insert() 返回 ≤0（Previewer/
// Simulator 中 RDB 写入不持久化时），自动切换到同会话内存缓存 MemStore，
// 保证演示环境也能完整展示所有功能。
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

// ── 同会话内存后备存储 ──────────────────────────────────────────────────────
// 当 RDB.insert() 返回 ≤0（Previewer 轻量模拟器不支持持久化写入）时激活。
// 激活后全部读写操作均走内存，保证 demo 流程完整可用。
// 真机/正式设备：active 永远 false，走正常 RDB 路径。
class MemStore {
  static active: boolean = false

  private static pets: Pet[] = []
  private static milestones: Milestone[] = []
  private static photos: PhotoItem[] = []
  private static health: HealthReminder[] = []
  private static weights: WeightEntry[] = []
  private static seq: number = 1001

  // ── pets ──
  static insertPet(src: Pet): number {
    const p = new Pet()
    p.id = MemStore.seq++
    p.name = src.name; p.species = src.species; p.breed = src.breed
    p.birthday = src.birthday; p.gender = src.gender; p.weightKg = src.weightKg
    p.avatarUri = src.avatarUri; p.createdAt = Date.now()
    MemStore.pets.push(p)
    return p.id
  }

  static updatePet(src: Pet): void {
    for (let i = 0; i < MemStore.pets.length; i++) {
      if (MemStore.pets[i].id === src.id) {
        MemStore.pets[i].name = src.name; MemStore.pets[i].species = src.species
        MemStore.pets[i].breed = src.breed; MemStore.pets[i].birthday = src.birthday
        MemStore.pets[i].gender = src.gender; MemStore.pets[i].weightKg = src.weightKg
        MemStore.pets[i].avatarUri = src.avatarUri
        return
      }
    }
  }

  static listPets(): Pet[] {
    const out: Pet[] = []
    for (let i = 0; i < MemStore.pets.length; i++) out.push(MemStore.pets[i])
    return out
  }

  static getPet(id: number): Pet | null {
    for (let i = 0; i < MemStore.pets.length; i++) {
      if (MemStore.pets[i].id === id) return MemStore.pets[i]
    }
    return null
  }

  static countPets(): number { return MemStore.pets.length }

  // ── milestones ──
  static insertMilestone(src: Milestone): number {
    const m = new Milestone()
    m.id = MemStore.seq++; m.petId = src.petId; m.type = src.type; m.title = src.title
    m.date = src.date; m.note = src.note
    m.photoUris = src.photoUris.slice()
    MemStore.milestones.push(m)
    return m.id
  }

  static listMilestones(petId: number): Milestone[] {
    const out: Milestone[] = []
    for (let i = 0; i < MemStore.milestones.length; i++) {
      if (MemStore.milestones[i].petId === petId) out.push(MemStore.milestones[i])
    }
    out.sort((a: Milestone, b: Milestone) => b.date - a.date)
    return out
  }

  static deleteMilestone(id: number): void {
    const next: Milestone[] = []
    for (let i = 0; i < MemStore.milestones.length; i++) {
      if (MemStore.milestones[i].id !== id) next.push(MemStore.milestones[i])
    }
    MemStore.milestones = next
  }

  // ── photos ──
  static insertPhoto(src: PhotoItem): number {
    const p = new PhotoItem()
    p.id = MemStore.seq++; p.petId = src.petId; p.uri = src.uri
    p.category = src.category; p.takenAt = src.takenAt
    MemStore.photos.push(p)
    return p.id
  }

  static listPhotos(petId: number, category: string): PhotoItem[] {
    const out: PhotoItem[] = []
    for (let i = 0; i < MemStore.photos.length; i++) {
      const p: PhotoItem = MemStore.photos[i]
      const matchPet: boolean = p.petId === petId
      const matchCat: boolean = category.length === 0 || category === 'all' || p.category === category
      if (matchPet && matchCat) out.push(p)
    }
    out.sort((a: PhotoItem, b: PhotoItem) => b.takenAt - a.takenAt)
    return out
  }

  static updatePhotoCategory(id: number, category: string): void {
    for (let i = 0; i < MemStore.photos.length; i++) {
      if (MemStore.photos[i].id === id) { MemStore.photos[i].category = category; return }
    }
  }

  static deletePhoto(id: number): void {
    const next: PhotoItem[] = []
    for (let i = 0; i < MemStore.photos.length; i++) {
      if (MemStore.photos[i].id !== id) next.push(MemStore.photos[i])
    }
    MemStore.photos = next
  }

  // ── health reminders ──
  static insertHealth(src: HealthReminder): number {
    const h = new HealthReminder()
    h.id = MemStore.seq++; h.petId = src.petId; h.type = src.type; h.title = src.title
    h.dueDate = src.dueDate; h.cycleMonths = src.cycleMonths; h.done = src.done; h.notify = src.notify
    MemStore.health.push(h)
    return h.id
  }

  static listHealth(petId: number): HealthReminder[] {
    const out: HealthReminder[] = []
    for (let i = 0; i < MemStore.health.length; i++) {
      if (MemStore.health[i].petId === petId) {
        const h: HealthReminder = MemStore.health[i]
        h.status = h.done ? 'ok' : DateUtil.reminderStatus(h.dueDate)
        out.push(h)
      }
    }
    out.sort((a: HealthReminder, b: HealthReminder) => a.dueDate - b.dueDate)
    return out
  }

  static markHealthDone(id: number): void {
    for (let i = 0; i < MemStore.health.length; i++) {
      if (MemStore.health[i].id === id) { MemStore.health[i].done = true; return }
    }
  }

  // ── weights ──
  static insertWeight(src: WeightEntry): number {
    const w = new WeightEntry()
    w.id = MemStore.seq++; w.petId = src.petId; w.weightKg = src.weightKg; w.recordedAt = src.recordedAt
    MemStore.weights.push(w)
    return w.id
  }

  static listWeights(petId: number): WeightEntry[] {
    const out: WeightEntry[] = []
    for (let i = 0; i < MemStore.weights.length; i++) {
      if (MemStore.weights[i].petId === petId) out.push(MemStore.weights[i])
    }
    out.sort((a: WeightEntry, b: WeightEntry) => a.recordedAt - b.recordedAt)
    return out
  }
}
// ─────────────────────────────────────────────────────────────────────────────

export class PetStore {
  // ════════════════ 宠物 ════════════════
  static async insertPet(pet: Pet): Promise<number> {
    if (MemStore.active) return MemStore.insertPet(pet)
    const vb: relationalStore.ValuesBucket = {
      'name': pet.name, 'species': pet.species, 'breed': pet.breed,
      'birthday': pet.birthday, 'gender': pet.gender, 'weight': pet.weightKg,
      'avatar': pet.avatarUri, 'created_at': Date.now()
    }
    const id: number = await Database.store().insert('pets', vb)
    if (id <= 0) {
      // RDB 写入未落盘（Previewer 环境），切换到内存模式
      MemStore.active = true
      return MemStore.insertPet(pet)
    }
    return id
  }

  static async updatePet(pet: Pet): Promise<void> {
    if (MemStore.active) { MemStore.updatePet(pet); return }
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
    if (MemStore.active) return MemStore.listPets()
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
    if (MemStore.active) return MemStore.getPet(id)
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
    if (MemStore.active) return MemStore.countPets()
    const pred = new relationalStore.RdbPredicates('pets')
    const rs = await Database.store().query(pred, ['id'])
    const n: number = rs.rowCount
    rs.close()
    return n < 0 ? 0 : n
  }

  // ════════════════ 里程碑 ════════════════
  static async insertMilestone(m: Milestone): Promise<number> {
    if (MemStore.active) return MemStore.insertMilestone(m)
    const vb: relationalStore.ValuesBucket = {
      'pet_id': m.petId, 'type': m.type, 'title': m.title,
      'date': m.date, 'note': m.note, 'photos': joinUris(m.photoUris)
    }
    const id: number = await Database.store().insert('milestones', vb)
    if (id <= 0) { MemStore.active = true; return MemStore.insertMilestone(m) }
    return id
  }

  static async listMilestones(petId: number): Promise<Milestone[]> {
    if (MemStore.active) return MemStore.listMilestones(petId)
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
    if (MemStore.active) { MemStore.deleteMilestone(id); return }
    const pred = new relationalStore.RdbPredicates('milestones')
    pred.equalTo('id', id)
    await Database.store().delete(pred)
  }

  // ════════════════ 相册 ════════════════
  static async insertPhoto(p: PhotoItem): Promise<number> {
    if (MemStore.active) return MemStore.insertPhoto(p)
    const vb: relationalStore.ValuesBucket = {
      'pet_id': p.petId, 'uri': p.uri, 'category': p.category, 'taken_at': p.takenAt
    }
    const id: number = await Database.store().insert('photos', vb)
    if (id <= 0) { MemStore.active = true; return MemStore.insertPhoto(p) }
    return id
  }

  static async listPhotos(petId: number, category: string): Promise<PhotoItem[]> {
    if (MemStore.active) return MemStore.listPhotos(petId, category)
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
    if (MemStore.active) return MemStore.listPhotos(petId, 'all').length
    const pred = new relationalStore.RdbPredicates('photos')
    pred.equalTo('pet_id', petId)
    const rs = await Database.store().query(pred, ['id'])
    const n: number = rs.rowCount
    rs.close()
    return n < 0 ? 0 : n
  }

  static async updatePhotoCategory(id: number, category: string): Promise<void> {
    if (MemStore.active) { MemStore.updatePhotoCategory(id, category); return }
    const vb: relationalStore.ValuesBucket = { 'category': category }
    const pred = new relationalStore.RdbPredicates('photos')
    pred.equalTo('id', id)
    await Database.store().update(vb, pred)
  }

  static async deletePhoto(id: number): Promise<void> {
    if (MemStore.active) { MemStore.deletePhoto(id); return }
    const pred = new relationalStore.RdbPredicates('photos')
    pred.equalTo('id', id)
    await Database.store().delete(pred)
  }

  // ════════════════ 健康提醒 ════════════════
  static async insertHealth(h: HealthReminder): Promise<number> {
    if (MemStore.active) return MemStore.insertHealth(h)
    const vb: relationalStore.ValuesBucket = {
      'pet_id': h.petId, 'type': h.type, 'title': h.title, 'due_date': h.dueDate,
      'cycle_months': h.cycleMonths, 'done': h.done ? 1 : 0, 'notify': h.notify ? 1 : 0
    }
    const id: number = await Database.store().insert('health_reminders', vb)
    if (id <= 0) { MemStore.active = true; return MemStore.insertHealth(h) }
    return id
  }

  static async listHealth(petId: number): Promise<HealthReminder[]> {
    if (MemStore.active) return MemStore.listHealth(petId)
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
    if (MemStore.active) { MemStore.markHealthDone(id); return }
    const vb: relationalStore.ValuesBucket = { 'done': 1 }
    const pred = new relationalStore.RdbPredicates('health_reminders')
    pred.equalTo('id', id)
    await Database.store().update(vb, pred)
  }

  // ════════════════ 体重 ════════════════
  static async insertWeight(w: WeightEntry): Promise<number> {
    if (MemStore.active) return MemStore.insertWeight(w)
    const vb: relationalStore.ValuesBucket = {
      'pet_id': w.petId, 'weight': w.weightKg, 'recorded_at': w.recordedAt
    }
    const id: number = await Database.store().insert('weights', vb)
    if (id <= 0) { MemStore.active = true; return MemStore.insertWeight(w) }
    return id
  }

  static async listWeights(petId: number): Promise<WeightEntry[]> {
    if (MemStore.active) return MemStore.listWeights(petId)
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
