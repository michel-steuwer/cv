#let mainfont = "Valkyrie OT B"
#let sansfont = "Concourse OT 3"
// #let accent   = rgb(11, 52, 95) /* dark blue */
#let accent   = rgb(177, 41, 41) /* TU Rot */
// #let accent   = rgb(234, 117, 47) /* TU Sekundär Orange */
// #let accent   = rgb(130, 42, 243) /* TU Sekundär Violett */
// #let accent   = rgb(72, 142, 198) /* TU Sekundär Blau */
// #let accent   = rgb(115, 200, 85) /* TU Sekundär Grün */
#let bright   = rgb(255,255,255)
#let gray     = rgb(79, 89, 97)
#let pageHeight   = 29.7cm
#let pageWidth    = 21cm
#let sidebar      = pageWidth/3
#let leftMargin   = 0.25cm
#let rightMargin  = 2cm;
#let topMargin    = 2.5cm;
#let bottomMargin = 3cm;

#let fa(name) = {
  text(
    font: "Font Awesome 6 Free",
    size: 9pt,
    box(name)
  )
}

#let fa-solid(name) = {
  text(
    font: "Font Awesome 6 Free Solid",
    size: 10pt,
    box(name)
  )
}

#let fa-brands(name) = {
  text(
    font: "Font Awesome 6 Brands",
    size: 10pt,
    box(name)
  )
}

#let envelope = symbol(
  "\u{f0e0}",
  ("open", "\u{f2b6}"),
  ("open.text", "\u{f658}"),
  ("square", "\u{f199}"),
)

#let entry(date: none, body) = {
  move(dx: -(2cm + 2*leftMargin),
      grid(
        columns: (2cm, 2*leftMargin, 100%),
        align(right + top, text(fill: bright, number-width: "tabular", date)),
        none,
        body
      )
    )
}

#let small(body) = text(size: 0.9em, body)

// bibliography
#let printPubs(pubs, labelPrefix) = {
  let priorDate = none
  let n = counter("n")
  n.update(pubs.len())

  for (key, pub) in pubs {
    let date = pub.at("date")
    if date == priorDate { date = "" } else { priorDate = date }
    
    let label = text(
      number-type: "lining",
      number-width: "tabular")[\[#labelPrefix#n.display()\]]

    let authors = {
      pub.at("author").map(name => {
        if name == "Michel Steuwer" { strong(name) } else { name }
      }).join(", ", last: " and ")
    }

    let venue = if pub.at("parent", default: none) != none {
      assert.eq(pub.at("parent").len(), 1)
      let venue = pub.at("parent").first()
      // "In: "
      text(style: "italic", venue.title)

      let volume = venue.at("volume", default: none)
      let issue = venue.at("issue", default: none)
      if volume != none and issue != none {
        [ #volume.#issue (#pub.at("date")).]
      } else if volume != none and issue == none {
        [ #volume (#pub.at("date")).]
      } else {
        [.]
      }

      let series = venue.at("parent", default: none)
      if series != none {
        assert.eq(series.len(), 1)
        series = series.first()
        [ In #series.title #series.volume.]
      }
    }

    let publisher = {
      let p = pub.at("publisher", default: none)
      if p != none {
        [ #p.]
      } else {
        let parent = pub.at("parent", default: none)
        if parent != none {
          assert.eq(pub.at("parent").len(), 1)
          let p = parent.first().at("publisher", default: none)
          if p != none {
            [ #p.]
          }
        }
      }
    }

    let note = {
      let note = pub.at("note", default: none)
      if note == none { none } else {
        [
          // highlight all mentions of citations
          #show regex("\d+ citations"): set text(fill: accent)
          // strongly highlight all citations over 30
          #show regex("([3-9]\d|[1-9]\d{2,}) citations"): set text(weight: "bold")
          // render syntax in notes
          #eval("[" + note + "]")
        ]
      }
    }

    entry(date: [#v(5pt)#text(weight: "bold")[#date] #h(1fr) #label])[
      #stack(
        dir: ttb,
        rect(fill: accent, width: 100%, inset: 5pt, outset: 1pt,
          text(fill: bright, weight: "bold", [
            #pub.at("title")
          ])),
        rect(stroke: 2pt + accent, width: 100%, inset: 5pt)[
            #authors
            
            #venue
            #publisher

            #note
        ]
      )
      //
      // #emph["#pub.at("title")"] by #authors.
      // #venue
      // #publisher
      // #note
      // 
    ]
    v(.5em)
    n.update(x => x - 1)
  }
}

// talks
#let printTalks(talks) = {
  for talk in talks {
    entry(date: [#talk.date])[
      #if talk.type == "invited-talk" {
        [*Invited Talk*: ]
      } else {
        [Talk: ]
      }
      #emph[#talk.title],
      #talk.parent.at(0).title,      
      #talk.parent.at(0).location.
    ]
  }
}

#let cv(
  name: "Name",
  title: none,
  address: (),
  email: none,
  date: none,
  doc
) = {
  set document(
    author: name,
    title: title + name + " - Resume"
  )
 
  set page(
    paper: "a4",
    margin: (
      left: sidebar + leftMargin,
      right: rightMargin,
      top: topMargin,
      bottom: bottomMargin
    ),

    footer:text(
        fill: accent,
        font: sansfont,
        size: 0.85em,
        grid(
        columns: (100%-(1/2 * sidebar), (1/2 * sidebar)),
        {
          set align(center)
          if date != none {
            [Last updated on #date]
          }
        },
        {
          set align(right)
          [Page #counter(page).display("1 of 1",both: true)]
        }
      )
    ),

    background: {
      set align(left)
      block(
        width: sidebar,
        height: pageHeight,
        fill: accent,
        move(dx: -1cm, dy: pageHeight - 4.05cm, // generalize ...
          rotate(-90deg,
            text(
              fill: bright,
              font: sansfont,
              size: 48pt,
              box(width: pageHeight, align(center, smallcaps(name))))
          )
        )
      )
    }
  )

  grid(
    columns: (65%, 35%),
    text(
      fill: accent,
      font: sansfont,
      size: 34pt,
      weight: "bold",
      style(styles => {
        let titleSize = measure(title, styles)
        move(dx: -(titleSize.width + leftMargin + .125em),
          box(width: 100% + titleSize.width)[
            #text(fill: bright, title) #name])
      })
    ),
    {
      set align(right)
      text(
        fill: gray,
        font: sansfont,
        number-type: "old-style",
        number-width: "tabular")[
          #address.join("\n") \
          #box(width: 200%, [#fa[#envelope] #email])
        ]
    }
  )
  
  set text(
    font: mainfont,
    number-type: "old-style",
    size: 11pt
  )

  set par(
    justify: true,
    leading: 0.78em
  )

  show heading.where(
    level: 1
  ): it => {
    set text(
      size: 14.4pt,
      fill: accent,
      font: sansfont,
      weight: "regular",
    )
    move(dx: -(2cm + 2*leftMargin),
      grid(
        columns: (2cm, 2*leftMargin, 100%),
        align(right + horizon, block(fill: bright, width: 2cm, height: 0.3em)),
        none,
        it
      )
    )
    v(.5em)
  }

  show heading.where(
    level: 2
  ): it => {
    set text(
      size: 12pt,
      fill: accent,
      font: sansfont,
      weight: "regular",
    )
    it
    v(.5em)
  }

  show strong: set text(fill: accent)

  show emph: set text(fill: accent, style: "normal")

  set list(
    marker: (move(dy: .5em - 0.11cm, circle(radius: 0.07cm, stroke: accent))),
    spacing: 1.5em
  )

  show list: it => {
    it
    v(.75em)
  }

  doc
}
