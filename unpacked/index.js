let store = { "dates": [] }
function initiate() {
	if (localStorage.getItem("absentees") === null) localStorage.setItem("absentees", JSON.stringify(store))
    else store = JSON.parse(localStorage.getItem("absentees"))
}

let absentees = []
let mode = "absentee"

function buttonCall(num) {
	let button = document.getElementById(num)
	if (button.className == "notSelected") {
		button.className = "selected"
		if (mode === "presentee") {
			button.style.background = getComputedStyle(document.documentElement).getPropertyValue('--success')
			button.style.color = getComputedStyle(document.documentElement).getPropertyValue('--text-color')
		} else {
			button.style.background = getComputedStyle(document.documentElement).getPropertyValue('--danger')
			button.style.color = '#fff'
		}
		absentees.push(button.innerHTML)
	} else {
		button.className = "notSelected"
		button.style.background = getComputedStyle(document.documentElement).getPropertyValue('--background-color')
        button.style.color = getComputedStyle(document.documentElement).getPropertyValue('--text-color')
        absentees.forEach((item, index) => {
			if (item === button.innerHTML) absentees.splice(index, 1)
		})
	}
}
function makeText() {
	let date = new Date()
	let label = mode === "presentee" ? "Presentees" : "Absentees"
    let text = `${label} on ${date.getDate()}/${date.getMonth()+1}/${date.getFullYear()}`
	absentees.sort()
	for (var i=0; i<absentees.length; i++) text += "\n"+absentees[i]
	return text
}
function openCopy(i) {
	navigator.clipboard.writeText(store.dates[i][1])
}
function openLog() {
    let open = document.getElementById("open")
    let openDiv = document.getElementById("openDiv")
    let text = ""
    if (open.innerHTML === "Open") {
        let sortedDates = [...store.dates].filter(arr => arr && arr[0] && typeof arr[0] === 'string').sort((a, b) => {
            const parseDate = str => {
                if (!str || typeof str !== 'string' || !str.includes(' @ ')) return new Date(0)
                let [datePart, timePart] = str.split(' @ ')
                if (!datePart || !timePart) return new Date(0)
                let [d, m, y] = datePart.split('/').map(Number)
                let [h, min, s] = timePart.split(':').map(Number)
                if ([d, m, y, h, min, s].some(isNaN)) return new Date(0)
                return new Date(y, m - 1, d, h, min, s)
            }
            return parseDate(b[0]) - parseDate(a[0])
        })
        for (var i = 0; i < sortedDates.length; i++) {
            text += `
            <div class="openShow">
                <div class="openHead">
                    <p id="openTitle">${sortedDates[i][0]}</p>
                </div>
                <hr/>
                <div id="openBody">
                    <span style="white-space: pre-line">${sortedDates[i][1]}</span><br>
                    <button id="openCopy" onclick="openCopy(${i})">Copy</button>
                </div>
            </div>`
        }
        open.innerHTML = "Close"
        storer.innerHTML = ""
        storer.style.marginBottom = "0"
        openDiv.innerHTML = text
    } else {
        open.innerHTML = "Open"
        openDiv.innerHTML = ""
        storer.style.marginBottom = "180px"
        setup()
    }
}
function save() {
	if (absentees.length != 0) {
		let date = new Date()
		let text = makeText()
		let obj = [`${date.getDate()}/${date.getMonth()+1}/${date.getFullYear()} @ ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`, text]
		store.dates.push(obj)
		localStorage.setItem("absentees", JSON.stringify(store))
		navigator.clipboard.writeText(text)
		for (let i = 0; i < absentees.length; i++) {
			let btn = document.getElementById(absentees[i]);
			if (btn) {
				btn.className = "notSelected";
				btn.style.background = getComputedStyle(document.documentElement).getPropertyValue('--background-color');
				btn.style.color = getComputedStyle(document.documentElement).getPropertyValue('--text-color');
			}
		}
		absentees = [];
		document.getElementById("save").innerHTML = "Saved & Copied!";
		setTimeout(() => { document.getElementById("save").innerHTML = "Save" }, 2000);
    }
}
function toggleMode() {
	mode = mode === "absentee" ? "presentee" : "absentee"
	for (let i = 0; i < absentees.length; i++) {
		let btn = document.getElementById(absentees[i])
        if (btn && btn.className === "selected") {
			if (mode === "presentee") {
				btn.style.background = getComputedStyle(document.documentElement).getPropertyValue('--success')
                btn.style.color = getComputedStyle(document.documentElement).getPropertyValue('--text-color')
            } else {
				btn.style.background = getComputedStyle(document.documentElement).getPropertyValue('--danger')
                btn.style.color = '#fff'
            }
		}
	}
	document.getElementById("toggleMode").innerHTML = mode === "absentee" ? "Toggle Mode" : "Toggle Mode"
}

const arrayRange = (start, stop, step) => Array.from({ length: (stop - start) / step + 1 }, (_, index) => start + index * step)
const storer = document.getElementById("storer")

let expa = ["Computer Science and Engineering", "Backlog"]
let deps = ["24CSE10", "23CSE10"]
let roll = [arrayRange(1, 57, 1), [3, 9, 41]]

function setup() {
	var dyn = ""
	var val = ""
	for (var i=0; i<deps.length; i++) {
		dyn += `<div class="separator">${expa[i]}</div>`
		for (var j of roll[i]) {
			val = deps[i]+j.toString().padStart(2, "0")
            dyn += `<button class="notSelected" id="${val}" onclick="buttonCall('${val}')">${val}</button>\n`
		}
	}
	storer.innerHTML = dyn
	for (var i=0; i<deps.length; i++) {
		for (var j of roll[i]) {
			val = deps[i]+j.toString().padStart(2, "0")
            let btn = document.getElementById(val)
            if (btn) {
				btn.style.background = getComputedStyle(document.documentElement).getPropertyValue('--background-color')
                btn.style.color = getComputedStyle(document.documentElement).getPropertyValue('--text-color')
            }
		}
	}
}
initiate()
setup()
