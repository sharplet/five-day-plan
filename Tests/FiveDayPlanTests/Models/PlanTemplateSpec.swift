@testable import FiveDayPlan
import Quick
import Nimble

final class PlanTemplateSpec: QuickSpec {
  override func spec() {
    let testTemplate = { try PlanTemplate(name: "test", bundle: testBundle) }

    describe("loading") {
      it("loads from a text file") {
        expect { try testTemplate() }.toNot(throwError())
      }

      it("fails to load if the text file doesn't exist") {
        let nonexistent = { try PlanTemplate(name: "nonexistent", bundle: testBundle) }
        expect { try nonexistent() }.to(throwError())
      }
    }

    describe("parsing") {
      it("extracts the first line as the week title") {
        let title = { try testTemplate().weeks.first?.title }
        expect { try title() } == "Test Week 1"
      }

      it("extracts multiple weeks separated by empty lines") {
        let titles = { try testTemplate().weeks.map { $0.title } }
        expect { try titles() } == ["Test Week 1", "Test Week 2", "Test Week 3"]
      }

      it("parses each line as a scripture collection for that day") {
        let chapters = { try testTemplate().weeks.first?.days.first?.chapters }
        expect { try chapters()?.at(0)?.description } == "Genesis 1"
        expect { try chapters()?.at(1)?.description } == "Proverbs 1"
        expect { try chapters()?.at(2)?.description } == "Proverbs 2"
        expect { try chapters()?.at(3)?.description } == "Proverbs 3"
        expect { try chapters()?.at(4)?.description } == "Mark 1"
        expect { try chapters()?.at(5)?.description } == "Mark 2"
        expect { try chapters()?.at(6)?.description } == "Titus"
      }
    }

    describe("2017") {
      it("exists") {
        expect(PlanTemplate.year2017).toNot(beNil())
      }
    }
  }
}
