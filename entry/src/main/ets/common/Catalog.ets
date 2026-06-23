// ============================================================
// 宠忆时光 - 业务分类映射（类型 → 字形/文案/色）
// entry/src/main/ets/common/Catalog.ets
// ============================================================

import { Theme } from './Theme'
import { Icons } from './Icons'
import { CategoryMeta } from '../model/PetModels'

export class Catalog {
  // ── 里程碑类型 ──
  static milestoneGlyph(type: string): string {
    if (type === 'birthday') return Icons.cake
    if (type === 'vaccine') return Icons.vaccine
    if (type === 'trip') return Icons.trip
    if (type === 'checkup') return Icons.checkup
    return Icons.flag
  }
  static milestoneLabel(type: string): string {
    if (type === 'birthday') return '生日'
    if (type === 'vaccine') return '疫苗'
    if (type === 'trip') return '出游'
    if (type === 'checkup') return '体检'
    return '自定义'
  }
  static milestoneColor(type: string): ResourceColor {
    if (type === 'vaccine') return Theme.color.accent
    if (type === 'trip') return Theme.color.typeTrip
    if (type === 'checkup') return Theme.color.success
    return Theme.color.primary
  }
  static milestoneTypes(): CategoryMeta[] {
    return [
      Catalog.meta('birthday', '生日'),
      Catalog.meta('vaccine', '疫苗'),
      Catalog.meta('trip', '出游'),
      Catalog.meta('checkup', '体检'),
      Catalog.meta('custom', '自定义')
    ]
  }

  // ── 健康类型 ──
  static healthGlyph(type: string): string {
    if (type === 'vaccine') return Icons.vaccine
    if (type === 'deworm') return Icons.bug
    if (type === 'checkup') return Icons.stethoscope
    if (type === 'weight') return Icons.weight
    return Icons.alert
  }
  static healthLabel(type: string): string {
    if (type === 'vaccine') return '疫苗'
    if (type === 'deworm') return '驱虫'
    if (type === 'checkup') return '体检'
    if (type === 'weight') return '体重'
    return '其他'
  }
  static healthTypes(): CategoryMeta[] {
    return [
      Catalog.meta('vaccine', '疫苗'),
      Catalog.meta('deworm', '驱虫'),
      Catalog.meta('checkup', '体检'),
      Catalog.meta('weight', '体重'),
      Catalog.meta('other', '其他')
    ]
  }

  // ── 健康状态语义色 ──
  static statusColor(status: string): ResourceColor {
    if (status === 'overdue') return Theme.color.error
    if (status === 'soon') return Theme.color.warning
    return Theme.color.success
  }

  // ── 相册分类 ──
  static photoCategories(): CategoryMeta[] {
    return [
      Catalog.meta('daily', '日常'),
      Catalog.meta('outdoor', '户外'),
      Catalog.meta('hospital', '医院'),
      Catalog.meta('food', '美食'),
      Catalog.meta('other', '其他')
    ]
  }
  static photoCategoryLabel(key: string): string {
    const list: CategoryMeta[] = Catalog.photoCategories()
    for (let i = 0; i < list.length; i++) {
      if (list[i].key === key) return list[i].label
    }
    return '其他'
  }

  static meta(key: string, label: string): CategoryMeta {
    const m: CategoryMeta = new CategoryMeta()
    m.key = key
    m.label = label
    return m
  }
}
