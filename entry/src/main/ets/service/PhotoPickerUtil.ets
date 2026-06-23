// ============================================================
// 宠忆时光 - 系统相册选图并落地到应用沙箱（保证重启后仍可访问）
// entry/src/main/ets/service/PhotoPickerUtil.ets
// ============================================================

import { picker, fileIo, fileUri } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG: string = 'ChongYiPicker'
const DOMAIN: number = 0xFF00

export class PhotoPickerUtil {
  // 选择图片，复制进沙箱，返回可供 Image 渲染的 file:// uri 列表
  static async pickAndStore(context: common.UIAbilityContext, maxCount: number): Promise<string[]> {
    const out: string[] = []
    try {
      const photoPicker = new picker.PhotoViewPicker()
      const opt: picker.PhotoSelectOptions = new picker.PhotoSelectOptions()
      opt.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      opt.maxSelectNumber = maxCount
      const result: picker.PhotoSelectResult = await photoPicker.select(opt)
      const uris: string[] = result.photoUris
      for (let i = 0; i < uris.length; i++) {
        const dest: string = context.filesDir + '/img_' + Date.now() + '_' + i + '.jpg'
        try {
          await fileIo.copyFile(uris[i], dest)
          out.push(fileUri.getUriFromPath(dest))
        } catch (copyErr) {
          hilog.error(DOMAIN, TAG, 'copy failed: ' + JSON.stringify(copyErr))
        }
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'pick cancelled/failed: ' + JSON.stringify(e))
    }
    return out
  }
}
