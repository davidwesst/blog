package main

import (
	"encoding/xml"
	"io/ioutil"
	"time"
)

type Root struct {
	XMLName xml.Name `xml:"rss"`
	Version string   `xml:"version,attr"`
	Channel *Channel `xml:"channel"`
}

type Item struct {
	XMLName     xml.Name       `xml:"item"`
	Title       string         `xml:"title"`
	Url         string         `xml:"link"`
	Description string         `xml:"description"`
	Published   time.Time      `xml:"pubDate"`
	Slug        string         `xml:"guid"`
	Tags        []string       `xml:"category"`
	Enclosure   *ItemEnclosure `xml:",omitempty"`
}

type ItemEnclosure struct {
	XMLName  xml.Name `xml:"enclosure"`
	Url      string   `xml:"url,attr"`
	MimeType string   `xml:"type,attr"`
	Size     int      `xml:"length,attr"`
}

type Channel struct {
	XMLName xml.Name `xml:"channel"`
	Title   string   `xml:"title"`
	Slug    string   `xml:"guid"`
	Link    string   `xml:"link"`
	Items   []*Item  `xml:"item"`
}

func newItem(title, slug, url, description string) *Item {
	i := Item{Title: title, Url: url, Description: description}
	return &i
}

func newItemEnclosure(url, mimeType string, size int) *ItemEnclosure {
	enc := ItemEnclosure{
		Url:      "https://www.davidwesst.com/blog/bllsdfskdf",
		Size:     12345678,
		MimeType: "text/html",
	}
	return &enc
}

func newItemFromPath(path string) *Item {
	location, _ := time.LoadLocation("America/Winnipeg")
	i := Item{
		Title:       "My Awesome Title",
		Url:         "https://www.davidwesst.com/blog/something/",
		Description: "This is a description & it's awesome!",
		Published:   time.Now().In(location),
		Slug:        "something",
		Tags:        []string{"tag1", "tag2"},
		Enclosure:   newItemEnclosure("1", "1", 1),
	}
	return &i
}

func getDefaultChannel() Channel {
	var defaultCollection Channel
	defaultCollection.Link = "https://www.davidwesst.com/blog/"
	defaultCollection.Title = "David Wesst // Blog"

	return defaultCollection
}

func main() {
	// setup channel
	coll := getDefaultChannel()

	// get items
	coll.Items = append(coll.Items, newItemFromPath(""), newItemFromPath(""), newItemFromPath(""))

	// collect as root
	root := Root{Version: "2.0", Channel: &coll}

	// marshal and output file
	metaFile, _ := xml.MarshalIndent(root, "", " ")
	_ = ioutil.WriteFile("index.xml", metaFile, 0644)
}
