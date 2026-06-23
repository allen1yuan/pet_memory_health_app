// ============================================================
// 宠忆时光 - 本地关系型数据库（RDB）初始化与 schema
// entry/src/main/ets/service/Database.ets
// ============================================================

import { relationalStore } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppConstants } from '../common/Constants'

const TAG: string = 'ChongYiDB'
const DOMAIN: number = 0xFF00

const DDL_PETS: string =
  'CREATE TABLE IF NOT EXISTS pets (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, species TEXT, breed TEXT, ' +
  'birthday INTEGER, gender TEXT, weight REAL, avatar TEXT, created_at INTEGER)'

const DDL_MILESTONES: string =
  'CREATE TABLE IF NOT EXISTS milestones (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER, type TEXT, title TEXT, ' +
  'date INTEGER, note TEXT, photos TEXT)'

const DDL_PHOTOS: string =
  'CREATE TABLE IF NOT EXISTS photos (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER, uri TEXT, category TEXT, taken_at INTEGER)'

const DDL_HEALTH: string =
  'CREATE TABLE IF NOT EXISTS health_reminders (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER, type TEXT, title TEXT, ' +
  'due_date INTEGER, cycle_months INTEGER, done INTEGER, notify INTEGER)'

const DDL_WEIGHTS: string =
  'CREATE TABLE IF NOT EXISTS weights (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, pet_id INTEGER, weight REAL, recorded_at INTEGER)'

export class Database {
  private static rdb: relationalStore.RdbStore | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (Database.rdb) return
    const config: relationalStore.StoreConfig = {
      name: AppConstants.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    try {
      const store = await relationalStore.getRdbStore(context, config)
      await store.executeSql(DDL_PETS)
      await store.executeSql(DDL_MILESTONES)
      await store.executeSql(DDL_PHOTOS)
      await store.executeSql(DDL_HEALTH)
      await store.executeSql(DDL_WEIGHTS)
      Database.rdb = store
      hilog.info(DOMAIN, TAG, 'RDB ready')
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'RDB init failed: ' + JSON.stringify(e))
      throw e as Error
    }
  }

  static store(): relationalStore.RdbStore {
    if (!Database.rdb) {
      throw new Error('Database not initialized — call Database.init(context) first')
    }
    return Database.rdb
  }

  static isReady(): boolean {
    return Database.rdb !== null
  }
}
