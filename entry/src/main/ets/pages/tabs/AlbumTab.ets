// ============================================================
// 宠忆时光 - 相册 Tab（手动添加 + 分类筛选 + 分享）
// entry/src/main/ets/pages/tabs/AlbumTab.ets
// ============================================================

import { common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { pasteboard } from '@kit.BasicServicesKit'
import { AppChip, PhotoTile, ShareSheet } from '../../components'
import { Theme } from '../../common/Theme'
import { Icons } from '../../common/Icons'
import { Catalog } from '../../common/Catalog'
import { PrefStore } from '../../service/PrefStore'
import { PetStore } from '../../service/PetStore'
import { PhotoPickerUtil } from '../../service/PhotoPickerUtil'
import { PhotoItem, CategoryMeta, Pet } from '../../model/PetModels'

@Component
export struct AlbumTab {
  @Prop @Watch('onTick') tick: number = 0

  @State photos: PhotoItem[] = []
  @State filter: string = 'all'
  @State petId: number = 0
  @State petName: string = ''
  @State showAdd: boolean = false
  @State addCategory: string = 'daily'
  @State showShare: boolean = false
  @State showPhotoDetail: boolean = false
  @State selectedPhoto: PhotoItem = new PhotoItem()
  private ctx: common.UIAbilityContext | null = null
  private categories: CategoryMeta[] = Catalog.photoCategories()

  async aboutToAppear(): Promise<void> {
    this.ctx = this.getUIContext().getHostContext()! as common.UIAbilityContext
    await this.reload()
  }

  onTick(): void { this.reload() }

  private async reload(): Promise<void> {
    this.petId = PrefStore.currentPetId()
    const pet: Pet | null = await PetStore.getPet(this.petId)
    this.petName = pet ? pet.name : ''
    this.photos = await PetStore.listPhotos(this.petId, this.filter)
  }

  private toast(msg: string): void { promptAction.showToast({ message: msg, duration: 1500 }) }

  private async confirmAdd(): Promise<void> {
    if (!this.ctx) return
    const uris: string[] = await PhotoPickerUtil.pickAndStore(this.ctx, 9)
    if (uris.length === 0) { this.showAdd = false; return }
    for (let i = 0; i < uris.length; i++) {
      const p = new PhotoItem()
      p.petId = this.petId; p.uri = uris[i]; p.category = this.addCategory; p.takenAt = Date.now() - i
      await PetStore.insertPhoto(p)
    }
    this.showAdd = false
    await this.reload()
    this.toast('已添加 ' + uris.length + ' 张照片')
  }

  private async copyCaption(): Promise<void> {
    const cap: string = this.shareCaption()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, cap)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showShare = false
      this.toast('文案已复制')
    } catch (e) {
      this.toast('复制失败')
    }
  }

  private openPhoto(p: PhotoItem): void {
    this.selectedPhoto = p
    this.showPhotoDetail = true
  }

  private async setPhotoCategory(category: string): Promise<void> {
    if (this.selectedPhoto.id <= 0) return
    await PetStore.updatePhotoCategory(this.selectedPhoto.id, category)
    this.selectedPhoto.category = category
    await this.reload()
    this.toast('分类已更新')
  }

  private async deleteSelectedPhoto(): Promise<void> {
    if (this.selectedPhoto.id <= 0) return
    await PetStore.deletePhoto(this.selectedPhoto.id)
    this.showPhotoDetail = false
    this.selectedPhoto = new PhotoItem()
    await this.reload()
    this.toast('照片已从本地相册移除')
  }

  private shareCaption(): string {
    const name: string = this.petName.length > 0 ? this.petName : '我的毛孩子'
    return '记录养 ' + name + ' 的每一天，每一刻都是惊喜🐾 #宠物日记 #养宠日常'
  }

  private thumbs(): string[] {
    const out: string[] = []
    for (let i = 0; i < this.photos.length && i < 3; i++) out.push(this.photos[i].uri)
    return out
  }

  @Builder addSheet() {
    Column({ space: 13 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('添加照片').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
      Text('归类到').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.categories, (c: CategoryMeta) => {
          Row() {
            AppChip({ label: c.label, selected: this.addCategory === c.key,
              onTap: (): void => { this.addCategory = c.key } })
          }.margin({ right: 8, bottom: 8 })
        })
      }.width('100%')
      Row({ space: 7 }) {
        Text(Icons.photoPlus).fontSize(18).fontColor(Theme.color.textOnPrimary)
        Text('选择照片并添加').fontSize(Theme.font.body).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
      }
      .width('100%').height(50).justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.color.primary).borderRadius(Theme.radius.md)
      .onClick(() => this.confirmAdd())
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  @Builder shareSheetBuilder() {
    ShareSheet({
      caption: this.shareCaption(),
      thumbUris: this.thumbs(),
      onCopy: (): void => { this.copyCaption() },
      onShare: (): void => { this.copyCaption() }
    })
  }

  @Builder photoDetailSheet() {
    Column({ space: 13 }) {
      Column().width(38).height(4).borderRadius(2).backgroundColor(Theme.color.borderDefault)
      Text('照片详情').fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium).width('100%')
      PhotoTile({
        uri: this.selectedPhoto.uri,
        badge: Catalog.photoCategoryLabel(this.selectedPhoto.category)
      }).width('100%')

      Text('修改分类').fontSize(Theme.font.footnote).fontColor(Theme.color.textTertiary).width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.categories, (c: CategoryMeta) => {
          Row() {
            AppChip({ label: c.label, selected: this.selectedPhoto.category === c.key,
              onTap: (): void => { this.setPhotoCategory(c.key) } })
          }.margin({ right: 8, bottom: 8 })
        })
      }.width('100%')

      Row({ space: 8 }) {
        Text(Icons.copy).fontSize(16).fontColor(Theme.color.primary)
        Text('复制分享文案').fontSize(Theme.font.caption).fontColor(Theme.color.primary)
      }
      .width('100%').height(44).justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.color.primaryDim).borderRadius(Theme.radius.md)
      .border({ width: 1, color: Theme.color.borderActive })
      .onClick(() => this.copyCaption())

      Text('删除这张照片记录')
        .fontSize(Theme.font.caption).fontColor(Theme.color.error)
        .width('100%').height(44).textAlign(TextAlign.Center)
        .backgroundColor(Theme.color.bgCard).borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.color.borderDefault })
        .onClick(() => this.deleteSelectedPhoto())
    }
    .width('100%').padding({ left: 18, right: 18, top: 14, bottom: 28 })
    .backgroundColor(Theme.color.bgDeep).borderRadius({ topLeft: 22, topRight: 22 })
  }

  @Builder filterRow() {
    Scroll() {
      Row({ space: 7 }) {
        AppChip({ label: '全部 ' + this.photos.length, selected: this.filter === 'all',
          onTap: (): void => { this.filter = 'all'; this.reload() } })
        ForEach(this.categories, (c: CategoryMeta) => {
          AppChip({ label: c.label, selected: this.filter === c.key,
            onTap: (): void => { this.filter = c.key; this.reload() } })
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%')
  }

  @Builder photoGrid() {
    if (this.photos.length === 0) {
      Column({ space: 10 }) {
        Text(Icons.album).fontSize(36)
          .width(72).height(72).textAlign(TextAlign.Center).borderRadius(36)
          .backgroundColor(Theme.color.bgCard).border({ width: 1, color: Theme.color.borderDefault })
        Text('还没有照片，点上方按钮添加吧').fontSize(Theme.font.caption).fontColor(Theme.color.textTertiary)
      }.width('100%').padding({ top: 60 }).justifyContent(FlexAlign.Center)
    } else {
      Grid() {
        ForEach(this.photos, (p: PhotoItem) => {
          GridItem() {
            PhotoTile({
              uri: p.uri,
              badge: p.category === 'daily' ? '' : Catalog.photoCategoryLabel(p.category),
              onTap: (): void => this.openPhoto(p)
            })
          }
        })
      }
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text((this.petName.length > 0 ? this.petName : '我') + ' 的相册')
          .fontSize(Theme.font.subtitle).fontColor(Theme.color.textPrimary).fontWeight(FontWeight.Medium)
        Blank()
        Text(Icons.share).fontSize(17).fontColor(Theme.color.textTertiary)
          .width(34).height(34).textAlign(TextAlign.Center).borderRadius(17)
          .backgroundColor(Theme.color.bgCard).border({ width: 1, color: Theme.color.borderDefault })
          .onClick(() => { this.showShare = true })
      }.width('100%').height(40).alignItems(VerticalAlign.Center)

      // 添加按钮 + 相册统计数
      Row() {
        Row({ space: 7 }) {
          Text(Icons.photoPlus).fontSize(16).fontColor(Theme.color.textOnPrimary)
          Text('添加照片').fontSize(Theme.font.caption).fontColor(Theme.color.textOnPrimary).fontWeight(FontWeight.Medium)
        }
        .padding({ left: 18, right: 18, top: 10, bottom: 10 })
        .linearGradient({ angle: 135, colors: [[Theme.color.primaryLight, 0], [Theme.color.primary, 1]] })
        .borderRadius(Theme.radius.pill)
        .shadow(Theme.shadow.buttonAmber)
        .onClick(() => { this.showAdd = true })
        Blank()
        Column({ space: 1 }) {
          Text(this.photos.length.toString()).fontSize(Theme.font.h3).fontColor(Theme.color.primary).fontWeight(FontWeight.Medium)
          Text('张照片').fontSize(Theme.font.micro).fontColor(Theme.color.textTertiary)
        }
      }.width('100%')

      this.filterRow()

      Scroll() {
        this.photoGrid()
      }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top)
    }
    .width('100%').height('100%')
    .padding({ left: 16, right: 16, top: 36 })
    .backgroundColor(Theme.color.bgBase)
    .bindSheet($$this.showAdd, this.addSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showAdd = false }
    })
    .bindSheet($$this.showShare, this.shareSheetBuilder(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showShare = false }
    })
    .bindSheet($$this.showPhotoDetail, this.photoDetailSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: Theme.color.bgDeep,
      onDisappear: (): void => { this.showPhotoDetail = false }
    })
  }
}
