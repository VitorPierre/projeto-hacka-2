import { Controller } from "@hotwired/stimulus"
import IMask from "imask"

export default class extends Controller {
  static values = {
    type: String
  }

  connect() {
    const maskOptions = this.getMaskOptions()
    if (maskOptions) {
      this.mask = IMask(this.element, maskOptions)
    }
  }

  disconnect() {
    if (this.mask) {
      this.mask.destroy()
    }
  }

  getMaskOptions() {
    switch (this.typeValue) {
      case "cpf":
        return { mask: '000.000.000-00' }
      case "phone":
        return { mask: '(00) 00000-0000' }
      case "money":
        return {
          mask: 'R$ num',
          blocks: {
            num: {
              mask: Number,
              thousandsSeparator: '.',
              padFractionalZeros: true,
              normalizeZeros: true,
              radix: ',',
              mapToRadix: ['.']
            }
          }
        }
      default:
        return null
    }
  }
}
