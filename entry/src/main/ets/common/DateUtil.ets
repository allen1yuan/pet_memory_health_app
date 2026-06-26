// ============================================================
// 宠忆时光 - 日期工具
// entry/src/main/ets/common/DateUtil.ets
// ============================================================

import { AppConstants } from './Constants'

export class DateUtil {
  static year(ts: number): number {
    return new Date(ts).getFullYear()
  }

  // "6月1日"
  static monthDay(ts: number): string {
    const d = new Date(ts)
    return (d.getMonth() + 1) + '月' + d.getDate() + '日'
  }

  // "2026-06-01"
  static ymd(ts: number): string {
    const d = new Date(ts)
    const m: string = ('0' + (d.getMonth() + 1)).slice(-2)
    const day: string = ('0' + d.getDate()).slice(-2)
    return d.getFullYear() + '-' + m + '-' + day
  }

  // 距今天数（正=已过去，负=未来）
  static daysSince(ts: number): number {
    return Math.floor((Date.now() - ts) / AppConstants.DAY_MS)
  }

  // 距到期描述："3天后" / "已逾期 2 天" / "今天"
  static dueText(dueTs: number): string {
    const diffDays: number = Math.ceil((dueTs - Date.now()) / AppConstants.DAY_MS)
    if (diffDays > 0) return diffDays + '天后'
    if (diffDays < 0) return '已逾期 ' + (-diffDays) + ' 天'
    return '今天'
  }

  // 提醒状态：'overdue' | 'soon' | 'ok'
  static reminderStatus(dueTs: number): string {
    const now: number = Date.now()
    if (dueTs < now) return 'overdue'
    if (dueTs < now + AppConstants.REMINDER_SOON_DAYS * AppConstants.DAY_MS) return 'soon'
    return 'ok'
  }

  static addMonths(ts: number, months: number): number {
    const d = new Date(ts)
    d.setMonth(d.getMonth() + months)
    return d.getTime()
  }
}
